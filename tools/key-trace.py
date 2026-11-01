#!/usr/bin/env python3
# Run on the phone as farmer: for 90 s, log touches and the keys the on-screen keyboard sends.
import glob, os, select, struct, time
fds = {}
for d in glob.glob("/sys/class/input/event*"):
    name = open(d + "/device/name").read().strip()
    if name in ("sec_touchscreen", "s10-osk", "gpio_keys") or "Keyboard" in name:
        fds[os.open("/dev/input/" + os.path.basename(d), os.O_RDONLY)] = name
print("watching", sorted(set(fds.values())), flush=True)
t0, last_touch = time.monotonic(), -9
while time.monotonic() - t0 < 90:
    r, _, _ = select.select(list(fds), [], [], 0.5)
    now = time.monotonic() - t0
    for fd in r:
        data = os.read(fd, 24 * 64)
        for i in range(0, len(data), 24):
            _, _, t, code, value = struct.unpack("qqHHi", data[i:i + 24])
            if fds[fd] == "sec_touchscreen":
                if now - last_touch > 0.5:
                    print(f"{now:6.2f} touch", flush=True); last_touch = now
            elif t == 1 and value == 1:
                print(f"{now:6.2f} {fds[fd]} key {code}", flush=True)
