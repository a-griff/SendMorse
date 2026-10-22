#!/bin/bash
# Send a custom message in Morse code at 650 Hz using SoX (Strict 1:3:7 Timing + Clickless Envelopes)
# SYNTAX: ./SendMorseCode.sh "message"

if [ -z "$1" ]; then
    echo "USAGE: $0 \"message\""
    exit 1
fi

FREQ=650
DOT=0.055  # Speed: ~22 WPM
DASH=$(awk "BEGIN {print $DOT * 3}")
LETTER_SPACE=$(awk "BEGIN {print $DOT * 3}")   # 3 units
WORD_SPACE=$(awk "BEGIN {print $DOT * 7}")     # 7 units (ITU Standard)

# Create temporary directory for audio blocks
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 1. Generate tone blocks with a tiny 3ms fade-in/fade-out to eliminate pops/clicks
sox -n -r 8000 -c 1 "$TEMP_DIR/dot.wav" synth $DOT sin $FREQ fade t 0.003 0 0.003
sox -n -r 8000 -c 1 "$TEMP_DIR/dash.wav" synth $DASH sin $FREQ fade t 0.003 0 0.003

# 2. Generate silence blocks
sox -n -r 8000 -c 1 "$TEMP_DIR/space_elem.wav" trim 0 $DOT
sox -n -r 8000 -c 1 "$TEMP_DIR/space_letter.wav" trim 0 $LETTER_SPACE
sox -n -r 8000 -c 1 "$TEMP_DIR/space_word.wav" trim 0 $WORD_SPACE

PLAY_LIST=()

# Morse code dictionary mapping
get_morse() {
    case "${1^^}" in
        # Letters
        A) echo ".-" ;;
        B) echo "-..." ;;
        C) echo "-.-." ;;
        D) echo "-.." ;;
        E) echo "." ;;
        F) echo "..-." ;;
        G) echo "--." ;;
        H) echo "...." ;;
        I) echo ".." ;;
        J) echo ".---" ;;
        K) echo "-.-" ;;
        L) echo ".-.." ;;
        M) echo "--" ;;
        N) echo "-." ;;
        O) echo "---" ;;
        P) echo ".--." ;;
        Q) echo "--.-" ;;
        R) echo ".-." ;;
        S) echo "..." ;;
        T) echo "-" ;;
        U) echo "..-" ;;
        V) echo "...-" ;;
        W) echo ".--" ;;
        X) echo "-..-" ;;
        Y) echo "-.--" ;;
        Z) echo "--.." ;;
        # Numbers
        1) echo ".----" ;;
        2) echo "..---" ;;
        3) echo "...--" ;;
        4) echo "....-" ;;
        5) echo "....." ;;
        6) echo "-...." ;;
        7) echo "--..." ;;
        8) echo "---.." ;;
        9) echo "----." ;;
        0) echo "-----" ;;
        # Punctuation
        ".") echo ".-.-.-" ;;
        ",") echo "--..--" ;;
        "?") echo "..--.." ;;
        "/") echo "-..-." ;;
        "-") echo "-....-" ;;
        "!") echo "---." ;;
        [[:space:]]) echo "SPACE" ;;
    esac
}

add_char() {
    local code="$1"
    for (( j=0; j<${#code}; j++ )); do
        local char="${code:j:1}"
        if [ "$char" = "." ]; then
            PLAY_LIST+=("$TEMP_DIR/dot.wav" "$TEMP_DIR/space_elem.wav")
        elif [ "$char" = "-" ]; then
            PLAY_LIST+=("$TEMP_DIR/dash.wav" "$TEMP_DIR/space_elem.wav")
        fi
    done
    
    # Default ending for a letter is a 3-unit letter space
    local last_idx=$((${#PLAY_LIST[@]} - 1))
    PLAY_LIST[$last_idx]="$TEMP_DIR/space_letter.wav"
}

echo "Transmitting message at 650 Hz (Clean Audio / Strict Timing)..."

# Parse input string character by character
MSG="$1"
for (( i=0; i<${#MSG}; i++ )); do
    char="${MSG:i:1}"
    morse=""

    if [ "$char" = "\\" ]; then
        next_char="${MSG:i+1:1}"
        if [ "$next_char" = "n" ]; then
            morse=".-.-" # AA prosign for newline
            i=$((i+1))
        fi
    else
        morse=$(get_morse "$char")
    fi
    
    if [ "$morse" = "SPACE" ]; then
        last_idx=$((${#PLAY_LIST[@]} - 1))
        if [ "$last_idx" -ge 0 ]; then
            PLAY_LIST[$last_idx]="$TEMP_DIR/space_word.wav"
        fi
    elif [ -n "$morse" ]; then
        add_char "$morse"
    fi
done

# Play the full sequence safely
if [ ${#PLAY_LIST[@]} -gt 0 ]; then
    play -q "${PLAY_LIST[@]}" 2>/dev/null
fi
echo "Done."
