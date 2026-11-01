#!/bin/sh
# Run the whole Sxmo session (dwm, menus, keyboard, apps) on the fast cores.
set -e
X=~/.config/sxmo/xinit
if ! grep -q "taskset -pc 4-7" $X; then
	tmp=$(mktemp)
	# insert right after the shebang so everything the session starts inherits it
	awk 'NR==1 {print; print "# S10: run the session on the fast A75/M4 cores (4-7), as Android does for the UI"; print "taskset -pc 4-7 $$ >/dev/null 2>&1"; next} {print}' $X > "$tmp"
	cat "$tmp" > $X && rm -f "$tmp"
fi
head -4 $X
