#!/usr/bin/env python3
# Print the metrics that matter for adding cell-filling glyphs to a monospace font.
import sys
from fontTools.ttLib import TTFont
f = TTFont(sys.argv[1])
print("unitsPerEm", f["head"].unitsPerEm, "glyf" in f and "TrueType" or "CFF")
print("hhea ascent/descent/lineGap", f["hhea"].ascent, f["hhea"].descent, f["hhea"].lineGap)
os2 = f["OS/2"]
print("OS/2 typo", os2.sTypoAscender, os2.sTypoDescender, os2.sTypoLineGap, "win", os2.usWinAscent, os2.usWinDescent)
cmap = f.getBestCmap()
print("advance M", f["hmtx"][cmap[ord("M")]][0], "glyphs", len(f.getGlyphOrder()))
print("names", [n.toUnicode() for n in f["name"].names if n.nameID in (1, 4, 6)][:6])
