# CachyOS & Hardware Tuning

CachyOS ships a tuned kernel and its own `cachyos-settings`, so this setup
deliberately **does not** re-apply generic Arch tuning on it. What it does instead is
expose the hardware-specific knobs CachyOS makes available but leaves at defaults.

## Platform detection

`is_cachyos()` checks, in order:

1. `/etc/cachyos-release` — **absent on current releases**, kept for older installs
2. `ID=cachyos` in `/etc/os-release` — authoritative
3. `pacman -Q cachyos-settings` — last-resort fallback

The `ID=` check matters: relying on `/etc/cachyos-release` alone silently
misidentifies a current CachyOS box as plain Arch, which would then get generic
sysctl and `pacman.conf` tuning applied *on top of* `cachyos-settings`.

## CPU: amd_pstate

Reported at install time:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver          # amd-pstate-epp
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
```

If the driver is `acpi-cpufreq` on an AMD system, the installer warns — add
`amd_pstate=active` to the kernel cmdline for proper scaling. CachyOS enables this
by default, so the warning normally never fires.

## Asymmetric X3D CPUs (7950X3D / 9950X3D)

Dual-CCD X3D parts have **one CCD with 3D V-Cache** (large L3, lower clock) and one
without (higher clock). Which CCD the scheduler prefers is a runtime switch:

```
/sys/bus/platform/drivers/amd_x3d_vcache/*/amd_x3d_mode
```

The default is often `frequency`, which is the wrong choice for gaming — games are
usually L3-bound and want the V-Cache CCD.

### x3d-mode

**Command**: `x3d-mode [show|cache|frequency]`
**Source**: `configs/scripts/x3d-mode.sh`
**Installed to**: `/usr/local/bin/x3d-mode` (root-owned)

```bash
x3d-mode              # show current mode
x3d-mode cache        # gaming    - prefer V-Cache CCD
x3d-mode frequency    # compiling - prefer high-clock CCD
```

It re-executes itself with `sudo` when changing the mode.

**Why `/usr/local/bin` and not `~/.local/bin`**: the optional GameMode integration
below grants passwordless `sudo` for this exact binary. If the binary lived in a
user-writable directory, that rule would be a trivial local privilege escalation.
Root-owned and root-writable only.

### Automatic switching with GameMode

Strictly opt-in, because it installs a sudoers rule. When enabled, the installer writes:

```
/etc/sudoers.d/10-x3d-mode

<user> ALL=(root) NOPASSWD: /usr/local/bin/x3d-mode cache, /usr/local/bin/x3d-mode frequency
```

Scoped to those two exact command lines — no wildcards, no shell. It is validated
with `visudo -c` and removed again if validation fails. GameMode's `[custom]`
`start`/`end` hooks then switch to `cache` when a game launches and back to
`frequency` when it exits, so compiles get the high-clock CCD automatically.

Decline the prompt and `x3d-mode` still works; you just switch manually.

## sched_ext (scx)

CachyOS kernels ship `sched_ext`, which allows swapping the CPU scheduler at
runtime. `scx-scheds` provides several:

| Scheduler | Use |
|-----------|-----|
| `scx_lavd` | Latency-tuned — the usual pick for gaming |
| `scx_bpfland` | Interactive desktop workloads |
| `scx_rusty` | General purpose, multi-domain |
| `scx_flash` | Deadline-based, latency sensitive |

The installer offers to enable `scx_loader.service` (a DBUS on-demand loader — note
the unit is `scx_loader.service`, **not** `scx.service`). Pick a scheduler with the
`scx-manager` GUI, or try one directly:

```bash
sudo scx_lavd
```

The installer does not write an scx config file — `scx_loader` is DBUS-driven and
has no documented static config, so inventing one would be guesswork.

## GPU

### Hybrid systems

GPU driver installation uses **independent checks, not an `if/elif` chain**. A
desktop with a discrete NVIDIA card and an AMD or Intel iGPU needs drivers for both;
an `elif` chain installs only the first match and silently leaves the iGPU on
fallback drivers.

### NVIDIA open kernel modules

Blackwell (RTX 50 series, `GB2xx`) has **no proprietary kernel module** — the open
modules are mandatory, not a preference. `nvidia_requires_open_modules()` detects
this from `lspci`, and the installer:

- installs `nvidia-open-dkms` rather than `nvidia`/`nvidia-dkms`
- on CachyOS, detects a `*-nvidia-open` kernel package already providing the modules
- warns if proprietary `nvidia`/`nvidia-dkms` packages are installed on such a GPU

Verify which module is loaded:

```bash
cat /proc/driver/nvidia/version     # "Open Kernel Module" on a correct setup
modinfo nvidia | grep license       # Dual MIT/GPL for the open modules
```

### Wayland environment

NVIDIA-specific Wayland variables (`GBM_BACKEND`, `__GLX_VENDOR_LIBRARY_NAME`,
`LIBVA_DRIVER_NAME`) are **not** set. They are auto-detected since nvidia-utils 555,
and forcing them on Plasma 6 is a known cause of black screens.
