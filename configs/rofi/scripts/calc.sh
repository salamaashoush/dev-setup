#!/usr/bin/env bash

# Rofi Calculator
# A simple calculator using rofi and bc/qalc

# Check for required calculator
if ! command -v qalc &>/dev/null && ! command -v bc &>/dev/null; then
    notify-send "Calculator Error" "Please install qalc or bc" -u critical
    exit 1
fi

# History file
HISTORY_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-calc-history"
mkdir -p "$(dirname "$HISTORY_FILE")"

# Load history
if [[ -f "$HISTORY_FILE" ]]; then
    HISTORY=$(tac "$HISTORY_FILE" | head -20)
else
    HISTORY=""
fi

# Custom theme
THEME_STR='
window {
    width: 500px;
}
listview {
    lines: 8;
}
entry {
    placeholder: "Enter calculation (e.g., 2+2, sqrt(16), sin(pi/2))";
}
'

# Main calculator loop
while true; do
    # Show rofi with history
    CALC=$(echo -e "$HISTORY" | rofi -dmenu -p "Calculator" \
        -theme-str "$THEME_STR" \
        -mesg "Press Enter to calculate, Escape to exit")
    
    # Exit if cancelled
    [[ -z "$CALC" ]] && exit 0
    
    # Calculate result
    if command -v qalc &>/dev/null; then
        # Use qalc for advanced calculations (qalc has its own input sanitization)
        RESULT=$(qalc -t "$CALC" 2>/dev/null)
    elif command -v bc &>/dev/null; then
        # Sanitize input for bc - only allow safe math characters
        # Allow: digits, operators, parentheses, decimal points, spaces, and bc functions
        if [[ "$CALC" =~ ^[0-9+\-*/^%\(\)\.\s\ sqrtsincoatanlogexp]+$ ]]; then
            RESULT=$(echo "scale=4; $CALC" | bc -l 2>/dev/null)
        else
            RESULT="Error: Invalid characters in expression"
        fi
    else
        RESULT="Error: Install qalc or bc"
    fi
    
    # If calculation successful
    if [[ -n "$RESULT" ]] && [[ "$RESULT" != "Error"* ]]; then
        # Save to history
        echo "$CALC = $RESULT" >> "$HISTORY_FILE"
        
        # Copy result to clipboard
        if [[ "$XDG_SESSION_TYPE" == "wayland" ]] || [[ "$WAYLAND_DISPLAY" != "" ]]; then
            echo -n "$RESULT" | wl-copy
        else
            echo -n "$RESULT" | xclip -selection clipboard
        fi
        
        # Update history for next iteration
        HISTORY=$(echo -e "$CALC = $RESULT\n$HISTORY" | head -20)
        
        # Show result
        notify-send "Calculator" "$CALC = $RESULT\n(Copied to clipboard)"
    else
        notify-send "Calculator Error" "Invalid expression: $CALC" -u critical
    fi
done