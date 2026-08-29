#!/usr/bin/env bash

# Open the host firewall (ufw) for multiplayer game hosting.
# Run as root: sudo game-firewall [--dry-run]
#
# ufw defaults to DROP on input, which silently breaks hosted games and, less
# obviously, UPnP discovery — see the LAN rule below.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

if ! command -v ufw &>/dev/null; then
    error "ufw is not installed"
fi

if [[ $EUID -ne 0 ]] && [[ "$DRY_RUN" == false ]]; then
    error "must run as root (sudo game-firewall)"
fi

detect_lan_cidr() {
    local iface
    iface=$(ip -4 route show default | awk '{print $5; exit}')
    [[ -z "$iface" ]] && return 1
    ip -4 route show dev "$iface" proto kernel scope link | awk '{print $1; exit}'
}

LAN_CIDR="${LAN_CIDR:-$(detect_lan_cidr || true)}"
[[ -z "$LAN_CIDR" ]] && error "could not detect LAN subnet; set LAN_CIDR=192.168.1.0/24 manually"

add() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "  would allow: $*"
    else
        ufw allow "$@" >/dev/null && echo -e "  ${GREEN}✓${NC} $*"
    fi
}

echo -e "${CYAN}LAN subnet: $LAN_CIDR${NC}"
echo
echo -e "${YELLOW}== LAN trust (also unblocks UPnP/SSDP discovery) ==${NC}"
add from "$LAN_CIDR"
add from fe80::/10

echo
echo -e "${YELLOW}== Steam platform (P2P, matchmaking, Remote Play) ==${NC}"
for r in \
    "4380/udp" \
    "27000:27100/udp" \
    "27015:27050/tcp" \
    "27031:27036/udp" \
    "27036:27037/tcp"
do add "$r"; done

echo
echo -e "${YELLOW}== Self-hosted game servers ==${NC}"
declare -A PORTS=(
    [openra]="1234/tcp"
    [warzone2100]="2100/tcp"
    [valheim]="2456:2458/udp"
    [supertuxkart]="2759/udp"
    [openttd]="3979/tcp 3979/udp"
    [mindustry]="6567/tcp 6567/udp"
    [terraria-ark-satisfactory-kf2]="7777:7778/tcp 7777:7778/udp"
    [assettocorsa]="8081/tcp 9600/tcp 9600/udp"
    [palworld]="8211/udp"
    [teeworlds]="8303/udp"
    [spring-bar]="8452/udp"
    [vrising]="9876:9877/udp"
    [dont-starve-together]="10998:11000/udp"
    [necesse]="14159/udp"
    [wesnoth]="15000/tcp"
    [satisfactory-extra]="15000/udp 15777/udp"
    [enshrouded]="15636:15637/udp"
    [project-zomboid]="16261:16262/tcp 16261:16262/udp"
    [minecraft-bedrock]="19132:19133/udp"
    [killingfloor2]="20560/tcp"
    [0ad]="20595/udp"
    [minecraft-voicechat]="24454/udp"
    [minecraft-java]="25565/tcp 25565/udp"
    [xonotic]="26000/udp"
    [7-days-to-die]="26900/tcp 26900:26903/udp"
    [quake-idtech]="27960/udp"
    [rust]="28015/udp 28016/tcp 28017/udp"
    [luanti-minetest]="30000/udp"
    [beamng]="30814/tcp 30814/udp"
    [factorio]="34197/udp"
    [vintage-story]="42420/tcp"
)

for game in $(echo "${!PORTS[@]}" | tr ' ' '\n' | sort); do
    echo -e "${CYAN}-- $game${NC}"
    for r in ${PORTS[$game]}; do add "$r"; done
done

if [[ "$DRY_RUN" == true ]]; then
    echo
    echo "Dry run — nothing changed."
    exit 0
fi

ufw logging low >/dev/null
ufw reload >/dev/null

echo
echo -e "${GREEN}Host firewall configured.${NC}"
echo "Next: verify the router with 'gamenet check'"
