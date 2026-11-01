#!/usr/bin/env python3
# Run on the phone as farmer: for 180 s, log button events, touch activity and the blank state.
import glob, os, select, time
fds = {}
for d in glob.glob("/sys/class/input/event*"):
    name = open(d + "/device/name").read().strip()
    if name in ("gpio_keys", "sec_touchscreen"):
        fds[os.open("/dev/input/" + os.path.basename(d), os.O_RDONLY)] = name
t0, last, last_touch = time.monotonic(), None, -9
def state():
    try: return open("/run/s10-blanked").read().strip()
    except OSError: return "-"
import subprocess
def lcd():
    out = subprocess.run(["dmesg"], capture_output=True, text=True).stdout
    i = out.rfind("lcd(")
    return out[i:i + 6] if i >= 0 else "?"
last_lcd = None
while time.monotonic() - t0 < 420:
    if int((time.monotonic() - t0) * 20) % 40 == 0:      # every ~2 s: panel state from the battery log
        l = lcd()
        if l != last_lcd:
            print(f"{time.monotonic() - t0:7.2f} panel {l}", flush=True); last_lcd = l
    r, _, _ = select.select(list(fds), [], [], 0.05)
    now = time.monotonic() - t0
    for fd in r:
        data = os.read(fd, 24 * 64)
        if fds[fd] == "gpio_keys":
            for i in range(0, len(data), 24):
                _, _, t, code, value = __import__("struct").unpack("qqHHi", data[i:i + 24])
                if t == 1: print(f"{now:7.2f} button {code} value {value}", flush=True)
        elif now - last_touch > 1:
            print(f"{now:7.2f} touch", flush=True); last_touch = now
    s = state()
    if s != last:
        print(f"{now:7.2f} blanked={s}", flush=True); last = s
