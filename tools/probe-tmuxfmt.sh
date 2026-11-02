#!/bin/sh
# Run on the phone: tmux version and how the window-status format expands.
tmux -V
tmux show -gw window-status-format
tmux display -p 'narrow=#{e|<:#{client_width},80} w=#{client_width}'
tmux list-windows -F '#{E:window-status-format}|'
