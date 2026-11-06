#!/usr/bin/env python3
# Summarise tools/power-log.txt: discharge stretches (screen-off samples, 5 min apart) and %/hour.
import datetime, re, sys
rows = []
for line in open(sys.argv[1]):
    m = re.match(r"(\d{4}-\d\d-\d\d \d\d:\d\d) (\d+)% (\w[\w ]*?) avg", line)
    if m:
        rows.append((datetime.datetime.strptime(m[1], "%Y-%m-%d %H:%M"), int(m[2]), m[3]))
dis = [r for r in rows if r[2] == "Discharging"]
print(f"samples {len(rows)}, discharging {len(dis)}: {dis[0][0]} {dis[0][1]}% -> {dis[-1][0]} {dis[-1][1]}%")
# split into stretches wherever two samples are more than 20 min apart (screen was on)
stretch, out = [dis[0]], []
for r in dis[1:]:
    if (r[0] - stretch[-1][0]).total_seconds() > 1200:
        out.append(stretch); stretch = [r]
    else:
        stretch.append(r)
out.append(stretch)
total_h = total_pct = 0
for s in out:
    h = (s[-1][0] - s[0][0]).total_seconds() / 3600
    pct = s[0][1] - s[-1][1]
    if h >= 0.5:
        total_h += h; total_pct += pct
        print(f"  {s[0][0]:%a %H:%M} -> {s[-1][0]:%a %H:%M}  {h:5.1f} h  {s[0][1]:3d}% -> {s[-1][1]:3d}%  {pct / h:4.2f} %/h")
print(f"screen-off total: {total_h:.1f} h, {total_pct}% -> {total_pct / total_h:.2f} %/h "
      f"= {100 / (total_pct / total_h):.0f} h for a full battery ({3400 * total_pct / 100 / total_h:.0f} mA average)")
span = (dis[-1][0] - dis[0][0]).total_seconds() / 3600
print(f"wall clock from first to last discharging sample: {span:.1f} h")
