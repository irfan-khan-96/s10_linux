#!/usr/bin/env python3
# Apply the scanline change to ~/fbterm-src/fbterm-1.7 (after live-resize and palette-refresh).
# FBTERM_SCANLINES=N darkens every Nth pixel row by half (CRT look); 0 or unset = off.
# With the screen rotated 90/270 degrees the physical columns are the text rows, so the
# check moves to x there and the lines stay horizontal relative to the text.
import os, sys
p = os.path.expanduser("~/fbterm-src/fbterm-1.7/src/screen_render.cpp")
s = open(p).read()

def sub(old, new):
    global s
    if s.count(old) != 1:
        sys.exit(f"expected one match for {old[:60]!r}")
    s = s.replace(old, new)

sub("static u32 fillColors[NR_COLORS];\n",
    "static u32 fillColors[NR_COLORS];\n"
    "static u32 scanPeriod, darkMask;    /* FBTERM_SCANLINES: darken every Nth row */\n"
    "static bool scanByColumn;           /* rotated 90/270: text rows are screen columns */\n"
    "#define DARK(c) (((c) >> 1) & darkMask)\n"
    "#define SCAN(n) (scanPeriod && (n) % scanPeriod == scanPeriod - 1)\n")

sub("\tppb = ppl >> 2;\n",
    "\tppb = ppl >> 2;\n\n"
    "\tconst char *scan = getenv(\"FBTERM_SCANLINES\");\n"
    "\tscanPeriod = scan ? strtoul(scan, 0, 10) : 0;\n"
    "\tdarkMask = mBitsPerPixel == 16 ? 0x7bef7bef : mBitsPerPixel == 15 ? 0x3def3def : mBitsPerPixel == 32 ? 0x7f7f7f : 0;\n"
    "\tif (!darkMask || scanPeriod < 2) scanPeriod = 0;\n"
    "\tscanByColumn = (mRotateType == Rotate90 || mRotateType == Rotate270);\n"
    "\tif (scanByColumn && mBitsPerPixel != 16) scanPeriod = 0;\n")

sub("""void Screen::fillX(u32 x, u32 y, u32 w, u8 color)
{
	u32 c = fillColors[color];
	u8 *dst = mVMemBase + y * mBytesPerLine + x * bytes_per_pixel;
""", """void Screen::fillX(u32 x, u32 y, u32 w, u8 color)
{
	u32 c = fillColors[color];
	u8 *dst = mVMemBase + y * mBytesPerLine + x * bytes_per_pixel;

	if (scanPeriod && scanByColumn) {	/* 16 bpp only: per pixel, darker on scan columns */
		for (u32 i = 0; i < w; i++, dst += 2) writew(dst, SCAN(x + i) ? DARK(c) : c);
		return;
	}
	if (!scanByColumn && SCAN(y)) c = DARK(c);
""")

sub("""	type *dst = (type *)(mVMemBase + y * mBytesPerLine + x * bytes_per_pixel); \\
 \\
	for (; w--; pixmap++, dst++) { \\
		pixel = *pixmap; \\
 \\
		if (!pixel) fbwrite(dst, fillColors[bc]); \\
		else if (pixel == 0xff) fbwrite(dst, fillColors[fc]); \\
		else { \\
			red = mPalette[bc].red + (((mPalette[fc].red - mPalette[bc].red) * pixel) >> 8); \\
			green = mPalette[bc].green + (((mPalette[fc].green - mPalette[bc].green) * pixel) >> 8); \\
			blue = mPalette[bc].blue + (((mPalette[fc].blue - mPalette[bc].blue) * pixel) >> 8); \\
 \\
			color = ((red >> (8 - lred) << (lgreen + lblue)) | (green >> (8 - lgreen) << lblue) | (blue >> (8 - lblue))); \\
			fbwrite(dst, color); \\
		} \\
	} \\
}""", """	type *dst = (type *)(mVMemBase + y * mBytesPerLine + x * bytes_per_pixel); \\
	bool rowDark = !scanByColumn && SCAN(y); \\
 \\
	for (u32 cx = x; w--; pixmap++, dst++, cx++) { \\
		pixel = *pixmap; \\
		bool dark = rowDark || (scanByColumn && SCAN(cx)); \\
 \\
		if (!pixel) color = fillColors[bc]; \\
		else if (pixel == 0xff) color = fillColors[fc]; \\
		else { \\
			red = mPalette[bc].red + (((mPalette[fc].red - mPalette[bc].red) * pixel) >> 8); \\
			green = mPalette[bc].green + (((mPalette[fc].green - mPalette[bc].green) * pixel) >> 8); \\
			blue = mPalette[bc].blue + (((mPalette[fc].blue - mPalette[bc].blue) * pixel) >> 8); \\
 \\
			color = ((red >> (8 - lred) << (lgreen + lblue)) | (green >> (8 - lgreen) << lblue) | (blue >> (8 - lblue))); \\
		} \\
		fbwrite(dst, dark ? (type)DARK(color) : color); \\
	} \\
}""")

if "#include <stdlib.h>" not in s:
    s = s.replace('#include "screen.h"', '#include <stdlib.h>\n#include "screen.h"', 1)
open(p, "w").write(s)
print("OK")
