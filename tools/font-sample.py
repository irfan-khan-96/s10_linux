#!/usr/bin/env python3
# Render a sample of the S10 VT font on a terminal grid (cell 22 x 57 px at size 56), amber on black.
# Usage: font-sample.py <font.ttf> <out.png>
import sys
from PIL import Image, ImageDraw, ImageFont
font = ImageFont.truetype(sys.argv[1], 56)
CW, CH = 22, 57
rows = ["┌──────┬──────┐ ╔═════╦═════╗ ┏━━━━┓",
        "│ box  │ text │ ║ dbl ║ ok  ║ ┃hvy┃",
        "├──────┼──────┤ ╠═════╬═════╣ ┗━━━━┛",
        "│ ▁▂▃▄▅▆▇█ ░▒▓ │ ╚═════╩═════╝ ←↑→↓",
        "└──────┴──────┘ ███████▌ 82%  ▲▼▶◀",
        "farmer@s10:~$ htop  [||||||    40%]",
        "⇧ ⌫ ⏎ ← → ↑ ↓   SHIFT DEL RET"]
img = Image.new("RGB", (CW * 38, CH * len(rows)), (6, 3, 0))
d = ImageDraw.Draw(img)
for r, line in enumerate(rows):
    for c, ch in enumerate(line):
        d.text((c * CW, r * CH), ch, font=font, fill=(255, 176, 0))
img.save(sys.argv[2])
