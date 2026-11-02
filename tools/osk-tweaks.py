#!/usr/bin/env python3
# Tweaks to pkg/s10-osk after the first amber round: type on touch (hold or flick up for the
# corner symbol), taller keyboard with tighter gaps, nearest-key hits, non-blocking lighter
# vibration, softer amber, filled keys, symbol labels, smaller pop-up.
import sys
p = "/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg/s10-osk"
s = open(p, encoding="utf-8").read()

def sub(old, new, count=1):
    global s
    if s.count(old) != count:
        sys.exit(f"expected {count} match(es) for {old[:70]!r}, found {s.count(old)}")
    s = s.replace(old, new)

sub('KB_H = int(os.environ.get("S10_OSK_HEIGHT", "1100"))', 'KB_H = int(os.environ.get("S10_OSK_HEIGHT", "1200"))')
sub('import datetime, fcntl, glob, mmap, os, select, struct, subprocess, time',
    'import datetime, fcntl, glob, mmap, os, select, struct, subprocess, threading, time')
sub('VIBRATOR = "/sys/class/timed_output/vibrator/enable"',
    'VIBRATOR = "/sys/class/timed_output/vibrator/enable"\n'
    'HAPTICS = "/etc/s10-haptics"                # vibration per key in ms; 0 = off')
sub('[("SHIFT", "m:SHIFT", 1.5)] + row("zxcvbnm") + [("DEL", "k:BKSP", 1.5)]',
    '[("⇧", "m:SHIFT", 1.5)] + row("zxcvbnm") + [("⌫", "k:BKSP", 1.5)]')
sub('[("SHIFT", "m:SHIFT", 1.5)] + row(",.?/$&*") + [("DEL", "k:BKSP", 1.5)]',
    '[("⇧", "m:SHIFT", 1.5)] + row(",.?/$&*") + [("⌫", "k:BKSP", 1.5)]')
sub('("RET", "k:ENTER", 1.8)', '("⏎", "k:ENTER", 1.8)', count=2)
sub('("SPACE", "c: ", 4.5)', '("", "c: ", 4.5)')
sub('("SPACE", "c: ", 3.4)', '("", "c: ", 3.4)')

sub('''# Amber phosphor, matching the palette s10-term loads into fbterm: outlined keys,
# amber labels, a key lights up solid amber while pressed.
BG, TEXT, DIM, HINT = (5, 2, 0), (255, 176, 0), (115, 75, 0), (150, 98, 0)
ACCENT, ACTIVE = (255, 176, 0), (70, 45, 0)                # pressed / held modifier fill
PAD = 10''', '''# Soft amber phosphor, matching the palette s10-term loads into fbterm: dark amber
# keys with amber labels; a key lights up solid amber while pressed.
BG, TEXT, DIM, HINT = (5, 2, 0), (232, 168, 60), (110, 76, 22), (140, 98, 34)
KEY, SPECIAL = (34, 22, 6), (24, 15, 4)                    # letter keys / function keys
ACCENT, ACTIVE = (232, 168, 60), (92, 62, 16)              # pressed / held modifier fill
PAD = 6''')

sub('''    def key_colour(self, action):
        if action.startswith("m:") and action[2:] in self.mods: return ACTIVE
        return BG''', '''    def key_colour(self, action):
        if action.startswith("m:") and action[2:] in self.mods: return ACTIVE
        return KEY if action.startswith("c:") else SPECIAL''')

sub('''        """Outlined key; pressed keys are filled amber with dark text."""
        b = (box[0] - dx, box[1] - dy, box[2] - dx, box[3] - dy)
        pressed = fill == ACCENT
        d.rectangle(b, fill=fill, outline=TEXT if pressed or fill == ACTIVE else DIM, width=3)''',
    '''        """Filled dark-amber key; pressed keys are solid amber with dark text."""
        b = (box[0] - dx, box[1] - dy, box[2] - dx, box[3] - dy)
        pressed = fill == ACCENT
        d.rectangle(b, fill=fill)''')

sub('''        w, h = (box[2] - box[0]) * 1.5, self.rh * 1.25''', '''        w, h = (box[2] - box[0]) * 1.2, self.rh * 0.95''')
sub('''        self.big = ImageFont.truetype(FONT, 130)''', '''        self.big = ImageFont.truetype(FONT, 110)''')

sub('''    def key_at(self, x, y):
        for box, label, action in self.keys:
            if box[0] - PAD <= x <= box[2] + PAD and box[1] - PAD <= y <= box[3] + PAD:
                return action
        return None''', '''    def key_at(self, x, y):
        """The key under the finger, or the nearest one (touches in a gap still count)."""
        best, dist = None, None
        for box, label, action in self.keys:
            dx = max(box[0] - x, 0, x - box[2])
            dy = max(box[1] - y, 0, y - box[3])
            if dx == dy == 0:
                return action
            if dist is None or dx * dx + dy * dy < dist:
                best, dist = action, dx * dx + dy * dy
        return best if dist is not None and dist < 60 * 60 else None''')

sub('''def buzz():
    try:
        with open(VIBRATOR, "w") as f: f.write("12")
    except OSError:
        pass''', '''def haptic_ms():
    try:
        with open(HAPTICS) as f:
            return max(int(f.read()), 0)
    except (OSError, ValueError):
        return 8
HAPTIC = haptic_ms()

def _vibrate():
    try:
        with open(VIBRATOR, "w") as f: f.write(str(HAPTIC))
    except OSError:
        pass

def buzz():
    """Short vibration, in the background: the driver call can take a few ms."""
    if HAPTIC:
        threading.Thread(target=_vibrate, daemon=True).start()''')

# typing: characters go out on touch; hold or flick up replaces it with the corner symbol
sub('''            before = self.kb.state()
            if not action.startswith("c:"):         # modifiers, layers, special keys: at once
                self.kb.press(action)
            if self.kb.state() != before:''', '''            before = self.kb.state()
            self.y0 = y
            if action != "c: ":                     # everything but space types at once
                self.kb.press(action)
            if self.kb.state() != before:''')

sub('''    def move(self, x, y, now):
        if self.target == "term":
            self.gestures.move(x, y, now)
        elif self.target == "key" and self.kb.pressed == "c: ":''', '''    def move(self, x, y, now):
        if self.target == "term":
            self.gestures.move(x, y, now)
        elif self.target == "key" and self.y0 - y > FLICK:
            self.alternate()                         # flick up: the corner symbol
        elif self.target == "key" and self.kb.pressed == "c: ":''')

sub('''            before = self.kb.state()
            if action.startswith("c:") and not (action == "c: " and self.steps):
                self.kb.press(action, self.kb.alt)
            self.kb.pressed = self.kb.alt = None''', '''            before = self.kb.state()
            if action == "c: " and not self.steps:  # space types on lift (it can swipe instead)
                self.kb.press(action)
            self.kb.pressed = self.kb.alt = None''')

sub('''        if action.startswith("c:") and self.kb.alt is None and self.kb.layer == "abc" \\
                and label in LONG and now - self.since > LONG_PRESS:
            self.kb.alt = LONG[label]
            buzz(); self.kb.show_pressed(action)
        elif''', '''        if action.startswith("c:") and now - self.since > LONG_PRESS:
            self.alternate()                         # held: the corner symbol
        elif''')

sub('''    def waiting(self):''', '''    def alternate(self):
        """Replace the letter just typed by the key's corner symbol (once per touch)."""
        action = self.kb.pressed
        label = action[2:]
        if not action.startswith("c:") or self.kb.alt is not None or self.kb.layer != "abc" \\
                or label not in LONG:
            return
        self.kb.alt = LONG[label]
        self.kb.tap(K["BKSP"])
        self.kb.press(action, self.kb.alt)
        self.kb.show_pressed(action)

    def waiting(self):''')

sub('''DEAD_ZONE = 80                              # px above the keyboard where touches are ignored''',
    '''DEAD_ZONE = 80                              # px above the keyboard where touches are ignored
FLICK = 70                                  # px upward on a key: type its corner symbol''')
open(p, "w", encoding="utf-8").write(s)
print("OK")
