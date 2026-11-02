#!/usr/bin/env python3
# Tweaks to pkg/s10-term and pkg/s10-splash: text size 64, softer amber palette, 1200 px keyboard.
import re, sys
S = "/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg"

t = open(f"{S}/s10-term", encoding="utf-8").read()
t = t.replace('|| echo 1100)"', '|| echo 1200)"')
t = t.replace("--font-size=56", "--font-size=64")
t = re.sub(r"palette='.*?'", """palette='0;5;2;0 1;235;110;60 2;214;190;96 3;235;188;80 4;180;126;52 5;222;132;92
6;226;180;118 7;232;168;60 8;110;76;22 9;245;130;90 10;232;208;120 11;242;204;110
12;245;195;100 13;240;160;116 14;240;204;150 15;250;220;160'""", t, flags=re.S)
t = t.replace("# Amber phosphor palette,", "# Soft amber phosphor palette,")
open(f"{S}/s10-term", "w", encoding="utf-8").write(t)

s = open(f"{S}/s10-splash", encoding="utf-8").read()
s = s.replace("AMBER, DIM, BG = (255, 176, 0), (115, 75, 0), (5, 2, 0)",
              "AMBER, DIM, BG = (232, 168, 60), (110, 76, 22), (5, 2, 0)")
s = s.replace("text = ImageFont.truetype(FONT, 300), ImageFont.truetype(FONT, 56)",
              "text = ImageFont.truetype(FONT, 300), ImageFont.truetype(FONT, 64)")
s = s.replace("y += 70", "y += 80").replace("160 + 8 * 22 + 10, y - 70 + 8, 160 + 9 * 22 + 6, y - 70 + 56",
                                             "160 + 8 * 26 + 10, y - 80 + 8, 160 + 9 * 26 + 6, y - 80 + 64")
open(f"{S}/s10-splash", "w", encoding="utf-8").write(s)
for f, needle in (("s10-term", "font-size=64"), ("s10-term", "echo 1200"), ("s10-splash", "232, 168, 60")):
    if needle not in open(f"{S}/{f}", encoding="utf-8").read():
        sys.exit(f"{f}: {needle} missing")
print("OK")
