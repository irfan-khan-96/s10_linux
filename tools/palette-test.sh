#!/bin/sh
# Run on the phone: how fbterm draws colour 8 via its own escape vs SGR 90, and what tmux sends.
tty=$(tmux list-clients -F '#{client_tty}' | head -1)
printf '\033[3;7;197;200;198}\033[12;5H\033[1;8}FBTERM-8 \033[0m\033[90mSGR-90 \033[0m\033[38;5;8mSGR256-8\033[0m' > "$tty"
TERM=fbterm tmux -f /dev/null -L probe new -d 'sleep 1' 2>/dev/null; tmux -L probe kill-server 2>/dev/null
ls /usr/share/terminfo/f/ 2>/dev/null | head; tmux show -s terminal-overrides; tmux show -s terminal-features
tmux display -p '#{client_termname} #{client_termfeatures} colours=#{client_termtype}'
