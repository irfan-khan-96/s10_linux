#!/bin/sh
# Remove setup leftovers from the phone user's home (all backed up on the PC).
cd "$HOME" || exit 1
rm -f ./*.sh ./*.py ./*.apk s10-osk s10-idle-blank
rm -rf __pycache__
rm -f .Xauthority .Xresources .Xresources.bak .fehbg .serverauth.* .s10-term.sh
cmp -s .tmux.conf /etc/tmux.conf && rm -f .tmux.conf
rm -rf .config/sxmo .cache/sxmo
ls -la | grep -v '^d'
du -sh "$HOME"
