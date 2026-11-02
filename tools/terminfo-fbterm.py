#!/usr/bin/env python3
# Run on the phone: colour-related terminfo entries for TERM=fbterm.
import curses
curses.setupterm("fbterm")
for cap in ("oc", "op", "setaf", "setab", "sgr0"):
    print(cap, repr(curses.tigetstr(cap)))
print("colors", curses.tigetnum("colors"))
