#!/usr/bin/env python3
# Run on the phone: which glyphs a font has (vs its "missing" box), and its cell size per pixel size.
# Usage: font-check.py <font.ttf>
import sys
from PIL import ImageFont
path = sys.argv[1]
def has(font, c):
    m, n = font.getmask(c), font.getmask("\U0010fffd")
    return m.size != n.size or bytes(m) != bytes(n)
f = ImageFont.truetype(path, 48)
groups = {"box": "─│┌┐└┘├┤┬┴┼═║╔╗╚╝╠╣", "blocks": "█▓▒░▀▄▌▐▂▃▅▆▇", "arrows": "←↑→↓⏎⌫⇧↻▲▼►◄",
          "misc": "•·°±×÷✓✗…»«¦§¶", "latin": "abcXYZ0129@#$%&*()[]{}<>/\\|~^`'\""}
for name, chars in groups.items():
    missing = "".join(c for c in chars if not has(f, c))
    print(f"{name:7} missing: {missing or '-'}")
for size in (36, 40, 44, 48, 52, 56):
    f = ImageFont.truetype(path, size)
    asc, desc = f.getmetrics()
    print(f"size {size}: advance {f.getlength('M'):.1f} px, line {asc + desc} px -> "
          f"portrait {1440 // round(f.getlength('M'))} cols x {1940 // (asc + desc)} rows")
