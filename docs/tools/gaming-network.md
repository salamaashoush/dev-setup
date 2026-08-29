# Gaming Network Documentation

Multiplayer hosting on Linux fails in a way that is hard to diagnose, because the
two things that break it both fail **silently** and one of them masks the other.

This page documents the two tools the setup installs, and the failure mode they exist to solve.

## The problem

Hosting a game needs an inbound path through three layers:

```
internet → ISP addressing → router (NAT) → host firewall → game
```

On a fresh Arch/CachyOS install with `ufw` enabled:

1. **`ufw` defaults to `DEFAULT_INPUT_POLICY="DROP"`.** Every hosted game port is
   blocked. No error, no log by default — peers simply cannot connect.
2. **The router has no port forward,** and cannot create one automatically unless
   UPnP is enabled.

The trap is the interaction. UPnP discovery is a multicast `M-SEARCH` to
`239.255.255.250:1900`; the router answers with a **unicast** reply. Conntrack cannot
match that reply to the multicast request, so `ufw` drops it. The result:

> You enable UPnP on the router, and `upnpc -l` still reports
> `No IGD UPnP Device found on the network!`

So the router fix appears not to work until the host firewall is fixed first.
**Always open `ufw` before concluding that router UPnP is broken.**

---

## gamenet

**Description**: Diagnose all three layers in one command
**Command**: `gamenet check [port]`
**Source**: `configs/scripts/gamenet.sh`

```bash
gamenet check              # firewall, router, ISP
gamenet check 25565        # ...plus end-to-end reachability for one port
sudo gamenet check 25565   # include the ufw rule check
```

Sample output:

```
== host firewall ==
  ✓ ufw active
  ✓ LAN trusted (192.168.1.0/24)
  ✓ port 25565 allowed

== router ==
  ✓ UPnP reachable - games can forward their own ports
  ✓ router WAN: 203.0.113.10
  active mappings:
    0 TCP 25565->192.168.1.50:25565 'libminiupnpc' '' 604800

== isp ==
  ✓ 203.0.113.10 - real IPv4, no CGNAT

== port 25565 end to end ==
  ✓ something is listening
  from internet: is open
```

Every failing line prints the exact command that fixes it.

**Other subcommands**:

| Command | Purpose |
|---------|---------|
| `gamenet maps` | List active UPnP mappings |
| `gamenet map <port> [tcp\|udp]` | Add a mapping for a game that lacks UPnP |
| `gamenet unmap <port> [tcp\|udp]` | Remove one |

**Requires**: `miniupnpc` (installed by `setup_gaming_network`).

**Note**: the end-to-end probe posts your public IP and port to a third-party port
checker. Omit the port argument to skip that.

### What it detects

- **CGNAT** — a public IP in `100.64.0.0/10` means port forwarding is impossible
  regardless of settings. The only fix is a tunnel (Tailscale, playit.gg) or asking
  the ISP for a real IPv4.
- **No IGD** — UPnP off at the router, or `ufw` eating the SSDP reply.
- **LAN not trusted** — the specific `ufw` gap that breaks UPnP discovery.

---

## game-firewall

**Description**: Open `ufw` for multiplayer hosting
**Command**: `sudo game-firewall [--dry-run]`
**Source**: `configs/scripts/game-firewall.sh`

Idempotent — safe to re-run. `--dry-run` prints what it would add without changing anything.

It adds three groups of rules:

1. **LAN trust** for the auto-detected local subnet, plus IPv6 link-local.
   This is what makes UPnP discovery work.
2. **Steam platform ranges** — UDP `4380`, `27000-27100`, `27031-27036`;
   TCP `27015-27050`, `27036-27037`. Covers matchmaking, P2P and Remote Play,
   and therefore most Steam titles including Age of Empires II: DE.
3. **~30 self-hosted game servers** — Minecraft (Java + Bedrock + voice chat),
   Valheim, Factorio, Terraria, Palworld, Rust, Project Zomboid, Satisfactory,
   7 Days to Die, V Rising, Enshrouded, OpenRA, OpenTTD, 0 A.D., and others.

The LAN subnet is derived from the default route, so it works on any network.
Override with `LAN_CIDR=10.0.0.0/24 sudo -E game-firewall`.

`DEFAULT_INPUT_POLICY` stays `DROP` — this opens specific ports, it does not
disable the firewall.

### Adding a game that is not covered

```bash
sudo ufw allow 12345/udp
gamenet map 12345 udp      # only if the game does not do UPnP itself
gamenet check 12345
```

---

## Router setup

One-time, in the router admin UI (`gamenet check` prints the address):

1. **Enable UPnP.** Games then forward their own ports with no per-game clicking.
2. **Give the machine a static DHCP lease,** so forwards do not break when the
   address changes.

Do **not** use DMZ / "exposed host" as a shortcut. It publishes every listening
port — SSH, container ports, kubelet — not just the game.

## Caveats

- **UPnP leases expire.** A mapping added by `gamenet map` carries a finite lease
  (commonly 7 days). Games that do their own UPnP refresh it every launch; manual
  mappings do not. Prefer enabling UPnP inside the game where the option exists.
- **Docker and k3s bypass `ufw` entirely.** They write their own iptables rules, so
  published container ports are reachable regardless of `ufw` state. `ufw` is not a
  container firewall.
- **A modem factory reset or ISP firmware push can silently turn UPnP back off.**
  `gamenet check` catches it in one command.
