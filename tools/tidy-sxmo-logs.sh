#!/bin/sh
# Run on the phone as farmer: remove log/state leftovers of Sxmo (removed 2026-11-01).
cd /home/farmer || exit 1
rm -rf .local/state/superd .local/state/tinydm.log .local/share/sxmo
du -sh /home/farmer
