#!/bin/bash
# Search the unpacked fbterm source: grep-fbterm.sh <pattern> [context]
cd ~/fbterm-src/fbterm-1.7/src && grep -rn -A"${2:-0}" -E "$1" --include=*.cpp --include=*.h .
