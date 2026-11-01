#!/bin/sh
# User-level terminal look for the S10 (run as farmer).
set -e
cat > ~/.fbtermrc <<'EOF'
# fbterm on the Galaxy S10 (1440x3040, ~550 dpi)
font-names=JetBrains Mono
font-size=36
font-width=
font-height=
# 0 = black (true black on AMOLED), 7 = light grey text
color-foreground=7
color-background=0
history-lines=2000
text-encodings=
cursor-shape=1
cursor-interval=0
word-chars=._-
screen-rotate=0
input-method=
EOF

cat > ~/.tmux.conf <<'EOF'
# Clean, fast tmux for the S10 terminal
set -g default-terminal "tmux-256color"
set -sg escape-time 0
set -g history-limit 20000
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g mouse off
# minimal status line: window list left, time and battery right
set -g status-position top
set -g status-style "bg=black,fg=colour244"
set -g status-left ""
set -g status-right "#(cat /sys/class/power_supply/battery/capacity)%%  %H:%M "
set -g status-interval 30
setw -g window-status-format " #I #W "
setw -g window-status-current-format " #I #W "
setw -g window-status-current-style "fg=white,bold"
set -g pane-border-style "fg=colour236"
set -g pane-active-border-style "fg=colour244"
set -g message-style "bg=black,fg=white"
EOF

# start the terminal session on tty2 for testing (tty1 is still Sxmo)
cat > ~/.s10-term.sh <<'EOF'
#!/bin/sh
export TERM=fbterm
exec fbterm -- tmux new -A -s main
EOF
chmod +x ~/.s10-term.sh
ls -la ~/.fbtermrc ~/.tmux.conf ~/.s10-term.sh
