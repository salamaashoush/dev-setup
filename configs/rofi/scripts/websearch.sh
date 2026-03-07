#!/usr/bin/env bash

# Rofi Web Search
# Quick web search with multiple search engines

# Check for xdg-open
if ! command -v xdg-open &>/dev/null; then
    notify-send "Web Search Error" "xdg-open not found" -u critical
    exit 1
fi

# Search engines
declare -A ENGINES=(
    ["🔍 Google"]="https://www.google.com/search?q="
    ["🦆 DuckDuckGo"]="https://duckduckgo.com/?q="
    ["🔎 Bing"]="https://www.bing.com/search?q="
    ["📹 YouTube"]="https://www.youtube.com/results?search_query="
    ["🐙 GitHub"]="https://github.com/search?q="
    ["📚 Wikipedia"]="https://en.wikipedia.org/wiki/Special:Search?search="
    ["🎬 IMDB"]="https://www.imdb.com/find?q="
    ["🛒 Amazon"]="https://www.amazon.com/s?k="
    ["📦 NPM"]="https://www.npmjs.com/search?q="
    ["🐍 PyPI"]="https://pypi.org/search/?q="
    ["🦀 Crates.io"]="https://crates.io/search?q="
    ["📖 ArchWiki"]="https://wiki.archlinux.org/index.php?search="
    ["🤖 ChatGPT"]="https://chat.openai.com/?q="
    ["🧠 Wolfram Alpha"]="https://www.wolframalpha.com/input/?i="
    ["💻 Stack Overflow"]="https://stackoverflow.com/search?q="
)

# Custom theme
THEME_STR='
window {
    width: 600px;
}
listview {
    lines: 15;
}
'

# Select search engine
ENGINE=$(printf '%s\n' "${!ENGINES[@]}" | sort | \
    rofi -dmenu -p "Search Engine" \
    -theme-str "$THEME_STR" \
    -matching fuzzy)

# Exit if no engine selected
[[ -z "$ENGINE" ]] && exit 0

# Get search query
QUERY=$(rofi -dmenu -p "$ENGINE" \
    -theme-str 'window {width: 600px;}' \
    -mesg "Enter search query:")

# Exit if no query
[[ -z "$QUERY" ]] && exit 0

# URL encode the query (handle common special characters)
# Note: %25 must come first, and + encoding must come after space encoding
ENCODED_QUERY=$(printf '%s' "$QUERY" | sed \
    -e 's/%/%25/g' \
    -e 's/&/%26/g' \
    -e 's/#/%23/g' \
    -e 's/?/%3F/g' \
    -e 's/=/%3D/g' \
    -e "s/'/%27/g" \
    -e 's/"/%22/g' \
    -e 's/ /+/g')

# Build URL
URL="${ENGINES[$ENGINE]}${ENCODED_QUERY}"

# Open in default browser
xdg-open "$URL" &

# Notify
notify-send "Web Search" "Searching '$QUERY' on $ENGINE"