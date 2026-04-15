#!/bin/bash
#
# encrypt.sh
# Password-based AES-256-CBC encryption for compressed files.
#
# Usage: ./encrypt.sh <input_file> <output_file>

set -euo pipefail

main() {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "$input_file" ]]; then
        zenity --error --title="Error" --text="File not found:\n${input_file}" --width=400
        exit 1
    fi

    local password
    password=$(zenity --password \
        --title="Set Encryption Password" \
        --width=400 2>/dev/null)
    [[ -z "$password" ]] && exit 0

    local confirm
    confirm=$(zenity --password \
        --title="Confirm Password" \
        --width=400 2>/dev/null)

    if [[ "$password" != "$confirm" ]]; then
        zenity --error --title="Error" --text="Passwords do not match." --width=400
        exit 1
    fi

    openssl enc -aes-256-cbc -pbkdf2 -iter 100000 \
        -in "$input_file" -out "$output_file" \
        -pass pass:"$password"

    local original_size encrypted_size
    original_size="$(wc -c < "$input_file")"
    encrypted_size="$(wc -c < "$output_file")"

    zenity --info \
        --title="Encryption Complete" \
        --text="File encrypted successfully.\n\nAlgorithm: AES-256-CBC (PBKDF2)\n\nOriginal Size:   ${original_size} bytes\nEncrypted Size:  ${encrypted_size} bytes" \
        --width=400 2>/dev/null
}

main "$@"
