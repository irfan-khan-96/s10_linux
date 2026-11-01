#!/bin/sh
# Run on the phone: which virtual console is active and what runs on the consoles.
echo "active console: $(cat /sys/class/tty/tty0/active)"
ps -o pid,tty,args | awk '$2 ~ /^tty[0-9]/'
grep -E '^tty' /etc/inittab
