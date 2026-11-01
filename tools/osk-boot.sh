#!/bin/sh
# Make s10-osk the boot-time keyboard (replacing buffyboard). Run as root.
set -e
install -m755 /home/farmer/osk-start.sh /usr/local/bin/s10-osk-start
cat > /etc/local.d/60-s10-osk.start <<'EOF'
#!/bin/sh
# on-screen keyboard in the strip fbterm leaves free (FBTERM_RESERVE_BOTTOM)
setsid /usr/local/bin/s10-osk > /tmp/osk.log 2>&1 < /dev/null &
EOF
chmod 755 /etc/local.d/60-s10-osk.start
apk del -q buffyboard fbkeyboard 2>/dev/null || true
rm -f /etc/buffyboard.conf
/usr/local/bin/s10-osk-start
sleep 3
ps -o pid,args | grep -E "[s]10-osk|[s]10-idle"
