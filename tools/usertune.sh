#!/bin/sh
# User-level Sxmo tweaks for the S10 (run as farmer, no sudo).
set -e
# screen timeout: Sxmo's idle lock/screen-off was disabled by this flag
rm -f ~/.cache/sxmo/sxmo.noidle
# stop the conky desktop clock, which redraws every second in software
X=~/.config/sxmo/xinit
grep -q "sxmo_conky" $X || printf '\n# S10: stop the conky desktop clock (redraws every second in software)\n(sleep 20; superctl stop sxmo_conky) &\n' >> $X
tail -3 $X
superctl stop sxmo_conky >/dev/null 2>&1 || true
sleep 1
pgrep -a conky || echo "conky stopped"
ls ~/.cache/sxmo/
