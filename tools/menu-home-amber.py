#!/usr/bin/env python3
# Replace the Home class in pkg/s10-menu with the framed amber home screen.
import re
p = "/mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg/s10-menu"
s = open(p, encoding="utf-8").read()
for old, new in (('"Notes"', '"notes"'), ('"Journal"', '"journal"'), ('"Write"', '"write"'),
                 ('"Shell"', '"shell"'), ('"System"', '"system"'), ('"Wi-Fi"', '"wi-fi"'), ('"Power"', '"power"')):
    s = s.replace(f"{old},", f"{new},", 1)
s = s.replace("# number or tap it (s10-osk turns taps into mouse clicks). Alt+m returns here.",
              "# number, by arrows + RET, or tap it (s10-osk turns taps into mouse clicks).\n"
              "# Alt+m returns here. Drawn in the amber palette s10-term loads into fbterm.")
start = s.index("class Home:")
end = s.index('if __name__ == "__main__":')
home = '''class Home:
    def __init__(self, scr):
        self.scr = scr
        self.sel = 0                               # highlighted item
        curses.curs_set(0)
        curses.use_default_colors()
        curses.mousemask(curses.BUTTON1_CLICKED | curses.BUTTON1_PRESSED | curses.BUTTON1_RELEASED)
        curses.mouseinterval(0)
        curses.init_pair(1, 8, -1)                 # dim amber
        curses.init_pair(2, 7, -1)                 # amber
        curses.init_pair(3, 15, -1)                # bright amber
        curses.init_pair(4, 0, 7)                  # inverse: selection
        curses.init_pair(5, 0, 9)                  # warning badge
        self.dim, self.text = curses.color_pair(1), curses.color_pair(2)
        self.bright, self.inverse = curses.color_pair(3), curses.color_pair(4)
        self.rows = {}                             # screen row -> item index

    def put(self, y, x, text, attr=0):
        h, w = self.scr.getmaxyx()
        if 0 <= y < h and 0 <= x < w - 1:
            self.scr.addnstr(y, x, text, w - 1 - x, attr)

    def frame(self, top, bottom, w, title, right):
        self.put(top, 0, "┌" + "─" * (w - 3) + "┐", self.dim)
        for y in range(top + 1, bottom):
            self.put(y, 0, "│", self.dim)
            self.put(y, w - 2, "│", self.dim)
        self.put(bottom, 0, "└" + "─" * (w - 3) + "┘", self.dim)
        self.put(top, 2, f" {title} ", self.bright)
        self.put(top, w - 4 - len(right), f" {right} ", self.text)

    def draw(self):
        scr = self.scr
        scr.erase()
        h, w = scr.getmaxyx()
        now = datetime.datetime.now()
        bat, charging, ssid, signal, ip = status()
        compact = h < 26                            # landscape: fewer blank rows
        bottom = h - 2
        self.frame(0, bottom, w, "S10 POCKET TERMINAL", f"{now:%H:%M}")
        y = 1 if compact else 2
        clock = big_clock(f"{now:%H:%M}")
        x = max((w - len(clock[0])) // 2, 2)
        for line in clock:
            self.put(y, x, line, self.text); y += 1
        date = f"{now:%A %d %B %Y}".upper()
        self.put(y + (0 if compact else 1), max((w - len(date)) // 2, 2), date, self.dim)
        y += 2 if compact else 3

        width = min(w - 22, 24)
        fill = round(width * bat / 100)
        self.put(y, 3, "BAT", self.dim)
        self.put(y, 8, "[" + "█" * fill + "░" * (width - fill) + "]", self.text)
        if bat <= 15 and not charging:
            self.put(y, 11 + width, f" LOW {bat}% ", curses.color_pair(5))
        else:
            self.put(y, 11 + width, f"{bat}%{' CHARGING' if charging else ''}", self.bright if charging else self.text)
        y += 1
        bars = "".join(b if signal >= t else "·" for b, t in zip("▂▄▆█", (1, 30, 55, 80)))
        self.put(y, 3, "NET", self.dim)
        self.put(y, 8, f"{bars} {ssid or 'OFFLINE'}"[: w - 12], self.text)
        if ip and 8 + len(bars) + len(ssid) + 4 + len(ip) < w - 3:
            self.put(y, w - 4 - len(ip), ip, self.dim)
        y += 1
        self.put(y, 3, "LOG", self.dim)
        self.put(y, 8, journal_line()[: w - 12], self.text)
        y += 1 if compact else 2

        self.put(y, 2, "─" * (w - 5), self.dim)
        y += 1 if compact else 2
        self.rows = {}
        step = 2 if bottom - y >= 2 * len(ITEMS) else 1
        for i, (key, label, _, _) in enumerate(ITEMS):
            if y >= bottom:
                break
            if i == self.sel:
                self.put(y, 3, f" > {key}  {label.upper():<{w - 15}}", self.inverse)
            else:
                self.put(y, 3, f"   {key}  ", self.dim)
                self.put(y, 9, label, self.text)
            for r in range(step):                 # the gap row below counts as the item too
                self.rows[y + r] = i
            y += step
        self.put(h - 1, 1, "↑↓ SELECT  RET OPEN  TAP  ALT+M HOME"[: w - 2], self.dim)
        scr.refresh()

    def power(self):
        scr = self.scr
        scr.erase()
        h, w = scr.getmaxyx()
        self.frame(0, 8, w, "POWER", "")
        self.put(2, 4, "R  REBOOT", self.text)
        self.put(4, 4, "P  POWER OFF", self.text)
        self.put(6, 4, "ANY OTHER KEY: BACK", self.dim)
        scr.refresh()
        scr.timeout(-1)
        k = scr.getch()
        if k in (ord("r"), ord("p")):
            curses.endwin()
            os.system("sudo reboot" if k == ord("r") else "sudo poweroff")

    def open(self, i):
        key, label, name, cmd = ITEMS[i]
        self.sel = i
        if cmd == "power":
            self.power()
        else:
            open_app(name, cmd)

    def run(self):
        while True:
            self.draw()
            self.scr.timeout(30000)                # refresh the clock and battery
            k = self.scr.getch()
            if k == -1:
                continue
            if k == curses.KEY_MOUSE:
                try:
                    _, _, my, _, state = curses.getmouse()
                except curses.error:
                    continue
                if state & (curses.BUTTON1_CLICKED | curses.BUTTON1_RELEASED) and my in self.rows:
                    self.open(self.rows[my])
            elif k in (curses.KEY_UP, ord("k")):
                self.sel = (self.sel - 1) % len(ITEMS)
            elif k in (curses.KEY_DOWN, ord("j")):
                self.sel = (self.sel + 1) % len(ITEMS)
            elif k in (curses.KEY_ENTER, 10, 13):
                self.open(self.sel)
            else:
                for i, item in enumerate(ITEMS):
                    if 0 < k < 256 and chr(k) == item[0]:
                        self.open(i)

'''
s = s[:start] + home + s[end:]
open(p, "w", encoding="utf-8").write(s)
print("OK")
