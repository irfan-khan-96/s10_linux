#!/usr/bin/env python3
# Time the on-screen keyboard's drawing paths without the framebuffer or uinput:
# osk-bench.py <s10-osk file>. Runs on the phone (or anywhere with numpy, Pillow and the font).
import sys, time, types
src = open(sys.argv[1]).read().replace('if __name__ == "__main__":\n    main()', '')
mod = types.ModuleType("osk"); exec(compile(src, "osk", "exec"), mod.__dict__)
np = mod.np
kb = mod.Keyboard.__new__(mod.Keyboard)
kb.font = mod.ImageFont.truetype(mod.FONT, 58); kb.small = mod.ImageFont.truetype(mod.FONT, 42)
kb.tiny = mod.ImageFont.truetype(mod.FONT, 28); kb.big = mod.ImageFont.truetype(mod.FONT, 96)
kb.layer, kb.mods, kb.pressed, kb.alt, kb.bases = "abc", set(), None, None, {}
kb.screen = np.zeros((mod.H_SCREEN, mod.W), dtype="<u2")
kb.layout()
def timed(label, f, n=10):
    t = time.perf_counter()
    for _ in range(n): f()
    print(f"{label}: {(time.perf_counter() - t) / n * 1000:.1f} ms")
timed("first full draw (renders the cache)", kb.draw, 1)
timed("full draw from cache", kb.draw)
timed("press g (key + pop-up)", lambda: kb.show_pressed("c:g"))
timed("release g", lambda: kb.show_released("c:g"))
timed("press Backspace", lambda: kb.show_pressed("k:BKSP"))
