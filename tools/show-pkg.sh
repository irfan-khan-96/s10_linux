#!/bin/bash
# Print package files: show-pkg.sh <file>...
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
for f in "$@"; do echo "===== $f"; cat "$f"; done
