# Game Development Documentation

Installed by `setup_game_development()`. Prompted, because it is a large download.

## Engines & content

| Tool | Purpose |
|------|---------|
| **Godot** | 2D/3D engine, GDScript and C# |
| **Blender** | Modelling, animation, asset authoring |

Rust engines (Bevy, macroquad, ggez) need no engine package — they come in through
`cargo`. What they do need are the system libraries listed below.

## Vulkan

| Package | Purpose |
|---------|---------|
| `vulkan-headers` | Build against the Vulkan API |
| `vulkan-tools` | `vulkaninfo`, `vkcube` |
| `vulkan-validation-layers` (+ `lib32-`) | Catch API misuse at runtime |
| `vulkan-icd-loader` (+ `lib32-`) | Driver loader |
| `spirv-tools`, `glslang`, `shaderc` | Shader compilation and inspection |

Verify the stack:

```bash
vulkaninfo --summary
```

Run with validation enabled:

```bash
VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation ./your-game
```

The 32-bit (`lib32-`) variants matter for Proton/Wine titles and for testing 32-bit
builds — without them, validation silently does not attach to 32-bit processes.

## Profiling & debugging

| Tool | Purpose |
|------|---------|
| **RenderDoc** | Frame capture, per-draw GPU state inspection |
| **Tracy** | Real-time frame profiler; has first-class Rust and C++ integrations |
| **lldb** / **gdb** | Native debugging |
| **MangoHud** | In-game FPS/frametime/GPU overlay (installed with the gaming packages) |

Tracy may be unavailable in the configured repos; the installer notes this rather
than failing, and it can be built from source.

## Rust game development on Linux

Bevy, `winit`, and friends link against system libraries that are easy to miss —
a missing one shows up as a confusing link error rather than "install this":

```
alsa-lib                                    audio
libxkbcommon                                keyboard
libx11 libxi libxcursor libxrandr libxinerama   X11 windowing
wayland wayland-protocols                   Wayland windowing
systemd-libs                                udev - gamepad/input hotplug
fontconfig                                  text rendering
```

Combined with the [mold linker](development.md#mold-linker), iteration on a Bevy
project is dominated by compile time rather than link time.

For web builds, the `wasm32-unknown-unknown` target is installed with the Rust
toolchain.

## Hardware notes

On an asymmetric X3D CPU, compiling and playtesting want *opposite* CCD preferences.
See [CachyOS & Hardware Tuning](cachyos-hardware.md) — `x3d-mode frequency` while
building, `x3d-mode cache` while playtesting, or let the GameMode hook do it.
