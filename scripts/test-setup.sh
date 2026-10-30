#!/usr/bin/env bash
# Checks the repo, then runs the no-sudo steps twice in a throwaway HOME: the
# second run must change nothing. CI runs this on macOS and Linux.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

echo "== shellcheck"
shellcheck -x -S warning install.sh bootstrap.sh scripts/*.sh configs/scripts/*.sh configs/rofi/scripts/*.sh

echo "== every links.txt source exists"
missing=0
while read -r mode _ src _; do
    [[ -z "$mode" || "$mode" == \#* ]] && continue
    [[ -e "configs/$src" ]] || { echo "missing configs/$src"; missing=1; }
done < configs/links.txt
[[ $missing -eq 0 ]]

echo "== configs parse"
python3 - <<'PY'
import json, pathlib, re, tomllib
for path in pathlib.Path("configs").rglob("*.toml"):
    tomllib.loads(path.read_text())
for path in pathlib.Path("configs").rglob("*.json"):
    text = re.sub(r"(?m)^\s*//.*$", "", path.read_text())
    json.loads(re.sub(r",(\s*[}\]])", r"\1", text))
print("toml and json ok")
PY

echo "== dotfiles and git, twice, in a throwaway HOME"
home="$(mktemp -d)"
trap 'rm -rf "$home"' EXIT
run() {
    env -i PATH="$PATH" HOME="$home" TERM=dumb ./install.sh --yes --only dotfiles,git </dev/null
}
run > "$home/first.log" 2>&1 || { cat "$home/first.log"; exit 1; }
run > "$home/second.log" 2>&1 || { cat "$home/second.log"; exit 1; }
if grep -q 'Backed up' "$home/second.log"; then
    echo "second run replaced files it had already linked:"
    grep 'Backed up' "$home/second.log"
    exit 1
fi
broken=$(find -L "$home" -type l | wc -l)
[[ $broken -eq 0 ]] || { echo "$broken broken links"; find -L "$home" -type l; exit 1; }
[[ "$(HOME="$home" git config --get core.pager)" == delta ]] || { echo "gitconfig include not applied"; exit 1; }

echo "all checks passed"
