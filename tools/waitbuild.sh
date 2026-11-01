#!/bin/bash
# Wait until pmbootstrap install has produced an image with the r2 kernel.
APK=~/.local/var/pmbootstrap/packages/edge/aarch64/s10-terminal-1-r0.apk
IMG=""
for i in $(seq 1 360); do
  if [ -f "$APK" ] && { [ -z "$IMG" ] || { [ -f "$IMG" ] && [ "$IMG" -nt "$APK" ] && tail -n 3 ~/s10-install.log 2>/dev/null | grep -q 'DONE!'; }; }; then
    echo "BUILD_READY $(date +%T)"; exit 0
  fi
  if tail -n 5 ~/s10-install.log 2>/dev/null | grep -q 'ERROR'; then
    echo "BUILD_ERROR"; tail -n 15 ~/s10-install.log; exit 1
  fi
  sleep 10
done
echo "TIMEOUT"; exit 2
