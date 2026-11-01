#!/bin/sh
# Run on the phone: why typing shows nothing (keyboard state, refresher, tmux, recent input).
echo "reserve: $(cat /run/s10-osk-reserve 2>&1)  blanked: $(cat /run/s10-blanked)  blanked-age: $(( $(date +%s) - $(stat -c %Y /run/s10-blanked) ))s"
pgrep -af 'msm-fb-refresher|s10-osk|s10-idle-blank|fbterm'
tmux list-windows -F '#I:#W #{pane_current_command} active=#{window_active}'
tmux list-clients -F 'client #{client_tty} #{client_width}x#{client_height}'
tmux capture-pane -p -t main | grep -v '^$' | tail -5
cat /tmp/osk.log
dmesg | grep -i -E 'decon|panel|dsim' | tail -5
