#!/bin/sh
# Run on the phone: press 1,2,3,5 in the menu, list the windows each opens, then close them again.
for k in 1 2 3 5 1; do
	tmux send-keys -t menu "$k"; sleep 1
	echo "after $k: $(tmux list-windows -F '#I:#W#F' | tr '\n' ' ')"
	tmux select-window -t menu
done
ls ~/journal ~/notes
for w in notes journal write system; do tmux send-keys -t "$w" "" 2>/dev/null; done
tmux kill-window -t notes; tmux kill-window -t journal; tmux kill-window -t write; tmux kill-window -t system
tmux list-windows -F '#I:#W'
