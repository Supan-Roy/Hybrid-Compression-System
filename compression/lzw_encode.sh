#!/bin/bash
#
# lzw_encode.sh
# LZW compression: reads input, outputs one integer code per line.
# Dictionary is rebuilt identically during decode — no need to store it.
#
# Usage: ./lzw_encode.sh <input_file> <output_file>

set -euo pipefail

[[ ! -f "$1" ]] && { echo "Error: file not found: $1" >&2; exit 1; }

awk '
BEGIN {
    # initialise dictionary with all single bytes 0-255
    for (i = 0; i < 256; i++) {
        dict[sprintf("%c", i)] = i
    }
    next_code = 256
    w = ""
    ORS = "\n"
}
{
    n = length($0)
    for (i = 1; i <= n; i++) {
        c  = substr($0, i, 1)
        wc = w c
        if (wc in dict) {
            w = wc
        } else {
            print dict[w]
            dict[wc] = next_code++
            w = c
        }
    }
    # newline character between lines
    wc = w "\n"
    if (wc in dict) {
        w = wc
    } else {
        print dict[w]
        dict[wc] = next_code++
        w = "\n"
    }
}
END {
    if (w != "") print dict[w]
}
' "$1" > "$2"
