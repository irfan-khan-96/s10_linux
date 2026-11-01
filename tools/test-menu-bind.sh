#!/bin/sh
# Run on the phone: does the Alt+m condition find the menu window?
tmux if-shell "tmux list-windows -F '##W' | grep -qx menu" "run-shell 'echo FOUND'" "run-shell 'echo NOT-FOUND'"
tmux if-shell "tmux list-windows -F '#W' | grep -qx menu" "run-shell 'echo old: FOUND'" "run-shell 'echo old: NOT-FOUND'"
