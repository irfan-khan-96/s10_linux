#!/bin/sh
# Run on the phone as farmer: fixed Alt+m binding for this tmux server, keep only the first menu window.
tmux bind -n M-m if-shell "tmux list-windows -F '##W' | grep -qx menu" "select-window -t menu" "new-window -b -t 1 -n menu s10-menu"
first=""
for w in $(tmux list-windows -F '#{window_id}:#W' | grep ':menu$' | cut -d: -f1); do
	if [ -z "$first" ]; then first=$w; else tmux kill-window -t "$w"; fi
done
tmux list-windows -F '#I:#W'
