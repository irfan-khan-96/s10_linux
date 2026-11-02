#!/bin/sh
# Run on the phone: take every tmux pane out of copy (scroll) mode.
for p in $(tmux list-panes -a -F '#{pane_id}:#{pane_in_mode}' | sed -n 's/:1$//p'); do
	tmux send-keys -t "$p" -X cancel
done
tmux list-windows -F '#I:#W mode=#{pane_in_mode}'
ls /usr/share/fonts/ /usr/share/fonts/misc/ | grep -E 'ter-u(28|32)|^[a-z]' | tr '\n' ' '
