#!/bin/sh
# Install fbterm + tools and start a test terminal on tty2 (Sxmo stays on tty1).
# Run with: sudo sh ~/termtest.sh      Back to Sxmo: Ctrl+Alt+F1 on the keyboard
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
echo "== installing fbterm (local build), tmux, fonts, editors"
apk add -q --allow-untrusted /home/farmer/fbterm-1.7-r0.apk
apk add -q tmux font-jetbrains-mono wordgrinder neovim ncurses-terminfo
fc-cache -f >/dev/null 2>&1 || true
fc-list | grep -i "jetbrains" | head -1
# terminfo entry for fbterm (256 colours); the package may not have installed it
infocmp fbterm >/dev/null 2>&1 || { tic /usr/share/terminfo/f/fbterm 2>/dev/null || true; }
infocmp fbterm >/dev/null 2>&1 && echo "terminfo fbterm: OK" || echo "terminfo fbterm: missing (will use TERM=linux)"
echo "== starting the terminal on tty8 and switching to it"
openvt -c 8 -s -- su -l farmer -c /home/farmer/.s10-term.sh
sleep 3
pgrep -a fbterm || echo "fbterm is NOT running"
echo "== done. Type on the USB keyboard. Back to Sxmo: Ctrl+Alt+F1"
