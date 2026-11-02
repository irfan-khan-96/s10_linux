#!/usr/bin/env python3
# Build "S10 VT": VT323 (OFL) plus the cell-filling glyphs it lacks, drawn on VT323's own
# grid (cell 400 x 1000 units, one VT pixel = 40 units) so lines and blocks join across cells:
# box drawing (light, heavy, double), block elements, shades, arrows and triangles.
# Usage: build-font.py <VT323-Regular.ttf> <out.ttf>
import sys
from fontTools.ttLib import TTFont
from fontTools.pens.ttGlyphPen import TTGlyphPen

src, out = sys.argv[1], sys.argv[2]
f = TTFont(src)
ADV, ASC, DESC, PX = 400, 800, -200, 40
# Overshoot one VT pixel past the cell so neighbours always touch: at sizes where the cell
# is a fractional number of pixels (64 px: 25.6) a flush edge gets anti-aliased into a seam.
L, R, B, T = -PX, ADV + PX, DESC - PX, ASC + PX
CX, CY = ADV // 2, (ASC + DESC) // 2               # 200, 300

def rects(rs):
    pen = TTGlyphPen(None)
    for x0, y0, x1, y1 in rs:
        if x1 <= x0 or y1 <= y0:
            continue
        pen.moveTo((x0, y0)); pen.lineTo((x0, y1)); pen.lineTo((x1, y1)); pen.lineTo((x1, y0)); pen.closePath()
    return pen.glyph()

def poly(points_list):
    pen = TTGlyphPen(None)
    for pts in points_list:
        pen.moveTo(pts[0])
        for p in pts[1:]:
            pen.lineTo(p)
        pen.closePath()
    return pen.glyph()

def lines(dirs, t=PX):
    """Single lines from the centre: dirs is a string of l, r, u, d."""
    h = t // 2
    rs = []
    if "l" in dirs: rs.append((L, CY - h, CX + h, CY + h))
    if "r" in dirs: rs.append((CX - h, CY - h, R, CY + h))
    if "d" in dirs: rs.append((CX - h, B, CX + h, CY + h))
    if "u" in dirs: rs.append((CX - h, CY - h, CX + h, T))
    return rs

# Double lines: rails at x = A, Bx and y = P, Q (one VT pixel thick, a pixel gap between).
A, BX, P, Q, HT = CX - 60, CX + 60, CY - 60, CY + 60, PX // 2
def hr(x0, x1, y):
    """Horizontal rail; ends that stop at a vertical rail cover that rail's width."""
    return (x0 if x0 == L else x0 - HT, y - HT, x1 if x1 == R else x1 + HT, y + HT)
def vr(x, y0, y1):
    return (x - HT, y0 if y0 == B else y0 - HT, x + HT, y1 if y1 == T else y1 + HT)
DOUBLE_RECTS = {
    "═": [hr(L, R, P), hr(L, R, Q)],
    "║": [vr(A, B, T), vr(BX, B, T)],
    "╔": [hr(A, R, Q), vr(A, B, Q), hr(BX, R, P), vr(BX, B, P)],
    "╗": [hr(L, BX, Q), vr(BX, B, Q), hr(L, A, P), vr(A, B, P)],
    "╚": [hr(A, R, P), vr(A, P, T), hr(BX, R, Q), vr(BX, Q, T)],
    "╝": [hr(L, BX, P), vr(BX, P, T), hr(L, A, Q), vr(A, Q, T)],
    "╠": [vr(A, B, T), vr(BX, B, P), vr(BX, Q, T), hr(BX, R, P), hr(BX, R, Q)],
    "╣": [vr(BX, B, T), vr(A, B, P), vr(A, Q, T), hr(L, A, P), hr(L, A, Q)],
    "╦": [hr(L, R, Q), hr(L, A, P), hr(BX, R, P), vr(A, B, P), vr(BX, B, P)],
    "╩": [hr(L, R, P), hr(L, A, Q), hr(BX, R, Q), vr(A, Q, T), vr(BX, Q, T)],
    "╬": [hr(L, A, P), hr(BX, R, P), hr(L, A, Q), hr(BX, R, Q),
          vr(A, B, P), vr(A, Q, T), vr(BX, B, P), vr(BX, Q, T)],
}

glyphs = {}
LIGHT = {"─": "lr", "│": "ud", "┌": "rd", "┐": "ld", "└": "ru", "┘": "lu", "├": "udr", "┤": "udl",
         "┬": "lrd", "┴": "lru", "┼": "lrud", "╭": "rd", "╮": "ld", "╯": "lu", "╰": "ru",
         "╴": "l", "╵": "u", "╶": "r", "╷": "d"}
HEAVY = {"━": "lr", "┃": "ud", "┏": "rd", "┓": "ld", "┗": "ru", "┛": "lu", "┣": "udr", "┫": "udl",
         "┳": "lrd", "┻": "lru", "╋": "lrud"}
for c, d in LIGHT.items(): glyphs[c] = rects(lines(d))
for c, d in HEAVY.items(): glyphs[c] = rects(lines(d, 2 * PX))
for c, rs in DOUBLE_RECTS.items(): glyphs[c] = rects(rs)

H = T - B
glyphs["█"] = rects([(L, B, R, T)])
glyphs["▀"] = rects([(L, CY, R, T)])
glyphs["▄"] = rects([(L, B, R, CY)])
glyphs["▌"] = rects([(L, B, CX, T)])
glyphs["▐"] = rects([(CX, B, R, T)])
for i, c in enumerate("▁▂▃▄▅▆▇"):                  # lower eighths (▄ is the half)
    glyphs[c] = rects([(L, B, R, B + H * (i + 1) // 8)])
for i, c in enumerate("▏▎▍▌▋▊▉"):                  # left eighths
    glyphs[c] = rects([(L, B, L + (R - L) * (i + 1) // 8, T)])
glyphs["▔"] = rects([(L, T - H // 8, R, T)])
glyphs["▕"] = rects([(R - (R - L) // 8, B, R, T)])
glyphs["■"] = rects([(40, CY - 160, 360, CY + 160)])
glyphs["▪"] = rects([(120, CY - 80, 280, CY + 80)])
def shade(keep):                                     # VT-pixel dither patterns
    rs = []
    for gy, y in enumerate(range(DESC, ASC, PX)):
        for gx, x in enumerate(range(0, ADV, PX)):
            if keep(gx, gy):
                rs.append((x, y, x + PX, y + PX))
    return rects(rs)
glyphs["░"] = shade(lambda x, y: x % 2 == 0 and y % 2 == 0)
glyphs["▒"] = shade(lambda x, y: (x + y) % 2 == 0)
glyphs["▓"] = shade(lambda x, y: not (x % 2 == 1 and y % 2 == 1))

# arrows and triangles, on the pixel grid
glyphs["→"] = poly([[(0, 260), (0, 340), (240, 340), (240, 480), (400, 300), (240, 120), (240, 260)]])
glyphs["←"] = poly([[(400, 260), (160, 260), (160, 120), (0, 300), (160, 480), (160, 340), (400, 340)]])
# keyboard symbols: shift (hollow up arrow), backspace, return
glyphs["⇧"] = poly([[(200, 640), (380, 400), (280, 400), (280, 40), (120, 40), (120, 400), (20, 400)],
                    [(200, 580), (100, 440), (160, 440), (160, 80), (240, 80), (240, 440), (300, 440)]])
glyphs["⌫"] = poly([[(0, 300), (120, 580), (400, 580), (400, 20), (120, 20)],
                    [(60, 300), (145, 100), (360, 100), (360, 500), (145, 500)],
                    [(160, 160), (210, 160), (330, 440), (280, 440)],
                    [(280, 160), (330, 160), (210, 440), (160, 440)]])
glyphs["⏎"] = poly([[(320, 220), (320, 560), (360, 560), (360, 180), (140, 180), (140, 60), (20, 200),
                     (140, 340), (140, 220)]])
glyphs["↑"] = poly([[(160, -40), (160, 440), (20, 440), (200, 640), (380, 440), (240, 440), (240, -40)]])
glyphs["↓"] = poly([[(240, 640), (240, 160), (380, 160), (200, -40), (20, 160), (160, 160), (160, 640)]])
glyphs["▲"] = poly([[(40, 120), (200, 520), (360, 120)]])
glyphs["▼"] = poly([[(40, 520), (360, 520), (200, 120)]])
glyphs["▶"] = poly([[(80, 100), (80, 500), (360, 300)]])
glyphs["◀"] = poly([[(320, 100), (40, 300), (320, 500)]])
glyphs["►"], glyphs["◄"] = glyphs["▶"], glyphs["◀"]

order = f.getGlyphOrder()
glyf, hmtx = f["glyf"], f["hmtx"]
for ch, g in glyphs.items():
    name = f"uni{ord(ch):04X}"
    if name not in order:
        order.append(name)
    glyf[name] = g
    g.recalcBounds(glyf)
    hmtx[name] = (ADV, getattr(g, "xMin", 0))
    for table in f["cmap"].tables:
        if table.isUnicode() and (table.format != 4 or ord(ch) <= 0xFFFF):
            table.cmap[ord(ch)] = name
f.setGlyphOrder(order)
f["maxp"].numGlyphs = len(order)
if "DSIG" in f:
    del f["DSIG"]                                    # the signature no longer matches
for rec in f["name"].names:                          # own name: a modified version of VT323
    if rec.nameID in (1, 16):
        rec.string = "S10 VT"
    elif rec.nameID == 3:
        rec.string = "S10 VT Regular; built from VT323 2.000"
    elif rec.nameID == 4:
        rec.string = "S10 VT Regular"
    elif rec.nameID == 6:
        rec.string = "S10VT-Regular"
f.save(out)
print(f"added {len(glyphs)} glyphs -> {out}")
