#!/bin/sh
# Run on the phone: how far back the kernel log reaches, and display lines in it.
dmesg | head -1
dmesg | wc -l
dmesg | grep -c -E 'panel|decon|dsim'
dmesg | grep -E 'panel|decon|dsim' | tail -15
