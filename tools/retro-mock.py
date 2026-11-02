#!/usr/bin/env python3
# Render full-resolution mockups (1440x3040) of retro styles for the S10 terminal, using
# VT323 for text (box lines and blocks drawn as the patched font would) and an outlined
# keyboard. Runs on the phone: retro-mock.py <VT323.ttf> <out dir>
import os, sys
from PIL import Image, ImageDraw, ImageFont

W, H, KB_H = 1440, 3040, 1100
TOP = H - KB_H
VT, OUT = sys.argv[1], sys.argv[2]
JB = "/usr/share/fonts/jetbrains-mono/JetBrainsMono-Regular.ttf"
SIZE = 56
font = ImageFont.truetype(VT, SIZE)
CW, CH = 22, 57                                  # VT323 at 56 px: 65 x 34 cells above the keyboard
sym = ImageFont.truetype(JB, 40)

STYLES = {
    "green": dict(name="Green phosphor (P1)", bg=(2, 8, 3), fg=(51, 255, 102), dim=(20, 110, 45),
                  hi=(180, 255, 200), panel=None, scan=True),
    "amber": dict(name="Amber phosphor (P3)", bg=(10, 5, 0), fg=(255, 176, 0), dim=(120, 80, 0),
                  hi=(255, 225, 150), panel=None, scan=True),
    "white": dict(name="Paper white (P4, DEC VT100)", bg=(4, 5, 8), fg=(215, 222, 235), dim=(95, 100, 112),
                  hi=(255, 255, 255), panel=None, scan=True),
    "vga": dict(name="Classic Linux console (VGA)", bg=(0, 0, 0), fg=(170, 170, 170), dim=(85, 85, 85),
                hi=(255, 255, 85), panel=(0, 0, 170), cyan=(85, 255, 255), scan=False),
    "green-flat": dict(name="Green phosphor, no scanlines", bg=(0, 0, 0), fg=(51, 255, 102), dim=(20, 110, 45),
                       hi=(180, 255, 200), panel=None, scan=False),
}

def text(d, col, row, s, colour, y0=0):
    d.text((col * CW, y0 + row * CH + 4), s, font=font, fill=colour)

def hline(d, c0, c1, row, colour, double=False):
    y = row * CH + CH // 2
    for off in ((-5, 5) if double else (0,)):
        d.rectangle((c0 * CW + CW // 2, y + off - 1, c1 * CW + CW // 2, y + off + 1), fill=colour)

def vline(d, col, r0, r1, colour, double=False):
    x = col * CW + CW // 2
    for off in ((-5, 5) if double else (0,)):
        d.rectangle((x + off - 1, r0 * CH + CH // 2, x + off + 1, r1 * CH + CH // 2), fill=colour)

def frame(d, c0, r0, c1, r1, colour, double=False):
    hline(d, c0, c1, r0, colour, double); hline(d, c0, c1, r1, colour, double)
    vline(d, c0, r0, r1, colour, double); vline(d, c1, r0, r1, colour, double)

def blocks(d, col, row, n, colour):
    d.rectangle((col * CW, row * CH + 8, (col + n) * CW - 3, row * CH + CH - 8), fill=colour)

def render(key, st):
    img = Image.new("RGB", (W, H), st["bg"])
    d = ImageDraw.Draw(img)
    fg, dim, hi = st["fg"], st["dim"], st["hi"]
    vga = key == "vga"
    # status bar
    if vga:
        d.rectangle((0, 0, W, CH), fill=(0, 170, 170))
        text(d, 0, 0, " 1 2 [3 shell] 4", (0, 0, 0))
        text(d, 44, 0, "wifi 82% 01:42", (0, 0, 0))
    else:
        text(d, 0, 0, " 1  2 ", dim); text(d, 6, 0, "[3 shell]", hi); text(d, 16, 0, " 4", dim)
        blocks(d, 43, 0, 1, fg); blocks(d, 44, 0, 1, fg); blocks(d, 45, 0, 1, fg); blocks(d, 46, 0, 1, dim)
        text(d, 49, 0, "82%  01:42", fg)
    # home screen panel
    r0, r1 = 2, 15
    if vga:
        d.rectangle((2 * CW, r0 * CH, 62 * CW, (r1 + 1) * CH), fill=st["panel"])
        frame(d, 3, r0, 61, r1, (255, 255, 255), double=True)
        text(d, 26, r0, " S10 ", (255, 255, 85))
        colour_title, colour_item, colour_key, colour_dim = (255, 255, 255), (255, 255, 255), (255, 255, 85), (170, 170, 170)
    else:
        frame(d, 1, r0, 63, r1, fg)
        text(d, 3, r0, " S10 pocket terminal ", hi)
        colour_title, colour_item, colour_key, colour_dim = hi, fg, hi, dim
    text(d, 6, r0 + 2, "01:42", colour_title)
    text(d, 14, r0 + 2, "Monday 02 November", colour_dim)
    text(d, 6, r0 + 4, "bat", colour_dim)
    blocks(d, 11, r0 + 4, 16, colour_item); blocks(d, 27, r0 + 4, 4, colour_dim)
    text(d, 33, r0 + 4, "82%", colour_item)
    text(d, 6, r0 + 5, "net  FRITZ!Box 7510   192.168.178.32", colour_dim)
    for i, (k, label) in enumerate([("1", "notes"), ("2", "journal"), ("3", "write"), ("4", "shell"),
                                    ("5", "system"), ("6", "wi-fi"), ("7", "power")]):
        row = r0 + 7 + i
        if i == 0:
            if vga:
                d.rectangle((5 * CW, row * CH, 30 * CW, (row + 1) * CH), fill=(0, 170, 170))
                text(d, 6, row, f"[{k}] {label}", (0, 0, 0))
            else:
                text(d, 5, row, f"> {k}  {label}", hi)
        else:
            text(d, 7 if not vga else 6, row, f"{k}  {label}" if not vga else f"[{k}] {label}", colour_key if False else colour_item)
    # shell session
    r = r1 + 2
    prompt_user = (85, 255, 85) if vga else hi
    lines = [("farmer@s10", ":~$ ", "ls"),
             None,
             ("farmer@s10", ":~$ ", "uptime"),
             ("", "", " 01:42:07 up 12 min,  load: 0.21, 0.30, 0.25"),
             ("farmer@s10", ":~$ ", "_")]
    for line in lines:
        if line is None:
            text(d, 0, r, "journal/", (85, 85, 255) if vga else hi)
            text(d, 10, r, "notes/", (85, 85, 255) if vga else hi)
            text(d, 18, r, "share/", (85, 85, 255) if vga else hi)
            text(d, 26, r, "hello.txt", fg)
        else:
            user, sep, rest = line
            if user:
                text(d, 0, r, user, prompt_user)
                text(d, len(user), r, sep, fg)
            if rest == "_":
                d.rectangle((len(user + sep) * CW, r * CH + 6, (len(user + sep) + 1) * CW - 2, r * CH + CH - 6), fill=fg)
            else:
                text(d, len(user + sep), r, rest, fg)
        r += 1
    # keyboard: outlined keys, VT323 labels
    rows = [["Esc", "Tab", "Ctrl", "Alt", "<", "v", "^", ">"], list("1234567890"), list("qwertyuiop"),
            list("asdfghjkl"), ["SHIFT"] + list("zxcvbnm") + ["DEL"], ["123", "-", "/", "SPACE", ".", "RET"]]
    widths = [[1] * 8, [1] * 10, [1] * 10, [1] * 9, [1.5] + [1] * 7 + [1.5], [1.5, 1, 1, 4.5, 1, 1.8]]
    kfont, sfont = ImageFont.truetype(VT, 76), ImageFont.truetype(VT, 50)
    rh = (KB_H - 10) / 6
    d.rectangle((0, TOP, W, H), fill=st["bg"])
    hline_y = TOP + 2
    d.rectangle((0, hline_y, W, hline_y + 2), fill=dim)
    for ri, (keys, ws) in enumerate(zip(rows, widths)):
        units = sum(ws); uw = (W - 10) / max(units, 10)
        x = (W - units * uw) / 2 + 5
        for k, w in zip(keys, ws):
            box = (x + 6, TOP + ri * rh + 12, x + w * uw - 6, TOP + (ri + 1) * rh)
            pressed = k == "g"
            if vga:
                d.rectangle(box, fill=(0, 170, 170) if pressed else (0, 0, 170))
                colour = (0, 0, 0) if pressed else (255, 255, 255)
            else:
                d.rectangle(box, fill=fg if pressed else st["bg"], outline=dim, width=3)
                colour = st["bg"] if pressed else fg
            f = kfont if len(k) == 1 else sfont
            d.text(((box[0] + box[2]) / 2, (box[1] + box[3]) / 2), k, font=f, fill=colour, anchor="mm")
            x += w * uw
    if st["scan"]:                                 # CRT texture: every 3rd pixel row darker
        px = img.load()
        dark = Image.new("RGB", (W, 1), (0, 0, 0))
        for y in range(0, H, 3):
            band = img.crop((0, y, W, y + 1))
            img.paste(Image.blend(band, dark, 0.45), (0, y))
    return img

os.makedirs(OUT, exist_ok=True)
thumbs = []
for key, st in STYLES.items():
    img = render(key, st)
    img.save(f"{OUT}/{key}.png")
    img.resize((W // 3, H // 3), Image.LANCZOS).save(f"{OUT}/{key}-small.png")
    thumbs.append(img.resize((W // 4, H // 4), Image.LANCZOS))
    print("rendered", key)
sheet = Image.new("RGB", (len(thumbs) * (W // 4 + 20), H // 4), (40, 40, 40))
for i, t in enumerate(thumbs):
    sheet.paste(t, (i * (W // 4 + 20), 0))
sheet.save(f"{OUT}/sheet.png")
