#!/bin/bash
# Try s10-menu on the phone without installing: copy to ~/.cache, open it as window "menu",
# and bind Alt+m for this tmux server only (lost on reboot).
set -e
scp -q /mnt/c/Users/irfan/Desktop/s10-postmarketos/tools/s10-menu s10:.cache/s10-menu
ssh s10 'python3 -m py_compile ~/.cache/s10-menu && rm -rf ~/.cache/__pycache__
tmux kill-window -t menu 2>/dev/null || true
tmux new-window -b -t main:1 -n menu "python3 ~/.cache/s10-menu"
tmux bind -n M-m if-shell "tmux list-windows -F \"#W\" | grep -qx menu" "select-window -t menu" "new-window -b -t 1 -n menu \"python3 ~/.cache/s10-menu\""
tmux list-windows'
