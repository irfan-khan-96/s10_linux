#!/bin/bash
# Rebuild pkg/S10VT-Regular.ttf and render a sample of it on the phone into mockups/font-sample.png.
set -e
cd /mnt/c/Users/irfan/Desktop/s10-postmarketos
~/s10-venv/bin/python tools/build-font.py fonts/VT323-Regular.ttf pkg/S10VT-Regular.ttf
scp -q pkg/S10VT-Regular.ttf s10:.cache/
ssh s10 python3 - .cache/S10VT-Regular.ttf .cache/sample.png < tools/font-sample.py
scp -q s10:.cache/sample.png mockups/font-sample.png
