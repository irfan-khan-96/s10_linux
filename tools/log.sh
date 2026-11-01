#!/bin/bash
L=~/.local/var/pmbootstrap/log.txt
echo "== key lines"
grep -nE 'error:|Error [0-9]|ERROR|>>> linux-samsung|Build complete|Kernel: arch|vmlinu|Image\.gz|packages/edge|sudo|losetup|timed out|incorrect password' "$L" | tail -40
echo "== built apks"
ls -la ~/.local/var/pmbootstrap/packages/edge/aarch64/ 2>/dev/null | grep -i beyond
