#!/usr/bin/env bash

# Diagnose the three layers between a game and the internet:
# host firewall (ufw) -> router (UPnP/IGD) -> ISP addressing (CGNAT).
#
# Usage:
#   gamenet check [port]         full diagnosis, optionally end-to-end for a port
#   gamenet map <port> [proto]   add a UPnP port mapping
#   gamenet unmap <port> [proto] remove one
#   gamenet maps                 list active mappings

set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()      { printf "  ${GREEN}✓${NC} %s\n" "$*"; }
bad()     { printf "  ${RED}✗${NC} %s\n" "$*"; }
warn()    { printf "  ${YELLOW}!${NC} %s\n" "$*"; }
section() { printf "\n${CYAN}== %s ==${NC}\n" "$*"; }

PUBLIC_IP=""

lan_ip()      { ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+'; }
lan_gateway() { ip -4 route show default | awk '{print $3; exit}'; }
lan_cidr() {
    local iface
    iface=$(ip -4 route show default | awk '{print $5; exit}')
    [[ -z "$iface" ]] && return 1
    ip -4 route show dev "$iface" proto kernel scope link | awk '{print $1; exit}'
}

require_upnpc() {
    command -v upnpc &>/dev/null || {
        bad "upnpc not installed (pacman -S miniupnpc / brew install miniupnpc)"
        return 1
    }
}

check_firewall() {
    section "host firewall"
    local cidr
    cidr=$(lan_cidr || echo "")

    if ! command -v ufw &>/dev/null; then
        warn "ufw not installed - not blocking anything"
        return
    fi

    if [[ $(systemctl is-active ufw 2>/dev/null) != active ]]; then
        warn "ufw inactive - not blocking anything"
        return
    fi
    ok "ufw active"

    local rules
    if ! rules=$(sudo -n ufw status 2>/dev/null); then
        warn "rule check needs sudo (run: sudo gamenet check ${1:-})"
        return
    fi

    if grep -q "$cidr" <<<"$rules"; then
        ok "LAN trusted ($cidr)"
    else
        bad "LAN not trusted - this also breaks UPnP discovery"
        echo "     fix: sudo game-firewall"
    fi

    local port="${1:-}"
    [[ -z "$port" ]] && return
    if grep -qE "^${port}[/ ]|^${port}:" <<<"$rules"; then
        ok "port $port allowed"
    else
        bad "port $port not allowed"
        echo "     fix: sudo ufw allow $port/tcp"
    fi
}

check_router() {
    section "router"
    require_upnpc || return

    local igd
    igd=$(timeout 15 upnpc -l 2>/dev/null)

    if ! grep -q 'Found valid IGD' <<<"$igd"; then
        bad "no UPnP IGD found"
        echo "     1. open the host firewall first: sudo game-firewall"
        echo "        (ufw drops the router's SSDP reply, so UPnP looks dead even when enabled)"
        echo "     2. enable UPnP in the router admin UI at http://$(lan_gateway)"
        return
    fi

    ok "UPnP reachable - games can forward their own ports"
    ok "router WAN: $(grep -oP 'ExternalIPAddress = \K\S+' <<<"$igd")"
    echo "  active mappings:"
    grep -E '^ *[0-9]+ (TCP|UDP)' <<<"$igd" | sed 's/^/   /' || echo "    (none)"
}

check_isp() {
    section "isp"
    PUBLIC_IP=$(curl -4 -s --max-time 8 ifconfig.me)

    if [[ -z "$PUBLIC_IP" ]]; then
        bad "no IPv4 egress"
    elif [[ $PUBLIC_IP =~ ^100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\. ]]; then
        bad "$PUBLIC_IP is CGNAT - port forwarding is impossible, use a tunnel (Tailscale, playit.gg)"
    else
        ok "$PUBLIC_IP - real IPv4, no CGNAT"
    fi
}

check_port_e2e() {
    local port="$1" pub="$2"
    section "port $port end to end"

    if ss -tuln | grep -qE "[:.]${port}\b"; then
        ok "something is listening"
    else
        bad "nothing listening - start the game or server first"
    fi

    [[ -z "$pub" ]] && return
    # Third-party probe: your public IP and port are sent to this service.
    printf "  from internet: "
    curl -s --max-time 20 -X POST -d "remoteAddress=${pub}&portNumber=${port}" \
        https://ports.yougetsignal.com/check-port.php 2>/dev/null \
        | grep -oE 'is (open|closed)' | head -1 || echo "probe failed"
}

cmd_check() {
    local port="${1:-}"
    check_firewall "$port"
    check_router
    check_isp
    [[ -n "$port" ]] && check_port_e2e "$port" "$PUBLIC_IP"
    echo
}

case "${1:-check}" in
    check) cmd_check "${2:-}" ;;
    map)
        require_upnpc || exit 1
        port="${2:?usage: gamenet map <port> [tcp|udp]}"
        proto=$(tr '[:lower:]' '[:upper:]' <<<"${3:-tcp}")
        upnpc -a "$(lan_ip)" "$port" "$port" "$proto" 2>&1 | tail -3
        ;;
    unmap)
        require_upnpc || exit 1
        port="${2:?usage: gamenet unmap <port> [tcp|udp]}"
        proto=$(tr '[:lower:]' '[:upper:]' <<<"${3:-tcp}")
        upnpc -d "$port" "$proto" 2>&1 | tail -3
        ;;
    maps)
        require_upnpc || exit 1
        timeout 15 upnpc -l 2>/dev/null | grep -E '^ *[0-9]+ (TCP|UDP)' || echo "(none)"
        ;;
    *)
        echo "usage: gamenet [check [port] | map <port> [proto] | unmap <port> [proto] | maps]"
        exit 1
        ;;
esac
