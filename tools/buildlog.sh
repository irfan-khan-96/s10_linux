#!/bin/bash
L=~/.local/var/pmbootstrap/log.txt
n=$(grep -n 'edge/fbterm: Building package' "$L" | tail -1 | cut -d: -f1)
sed -n "$n,\$p" "$L" | grep -nE 'error|Error|ERROR|applying|Hunk|FAILED|fatal|undefined|No such|>>> fbterm' | head -40
echo "== last 25 lines before failure"
sed -n "$n,\$p" "$L" | grep -n '\^\^\^' | head -1
m=$(sed -n "$n,\$p" "$L" | grep -n '\^\^\^' | head -1 | cut -d: -f1)
[ -n "$m" ] && sed -n "$((n+m-26)),$((n+m-1))p" "$L"
