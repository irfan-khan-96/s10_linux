#!/bin/sh
export TERM=fbterm
# leave the bottom 1100 px to the on-screen keyboard (buffyboard)
export FBTERM_RESERVE_BOTTOM=1100
exec fbterm -- tmux new -A -s main
