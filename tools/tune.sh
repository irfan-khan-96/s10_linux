#!/bin/sh
# Responsiveness tuning for the S10 (applied now and at every boot).
# Run with: sudo sh ~/tune.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

cat > /etc/local.d/40-s10-tuning.start <<'EOF'
#!/bin/sh
# Samsung input booster: raise CPU clocks for ~1 s on touch, as Android does.
# Android's init enables it; on Linux it starts disabled.
echo 1 > /sys/class/input_booster/enable_event
# schedutil: ramp clocks up within 0.5 ms of load (was 4 ms), drop them after
# 20 ms (was 4 ms), so short bursts like redraws do not run at low clocks.
for p in /sys/devices/system/cpu/cpufreq/policy*; do
	echo schedutil > $p/scaling_governor
	echo 500 > $p/schedutil/up_rate_limit_us
	echo 20000 > $p/schedutil/down_rate_limit_us
done
EOF
chmod 755 /etc/local.d/40-s10-tuning.start
/etc/local.d/40-s10-tuning.start

# Wi-Fi power saving adds latency to SSH and the share; turn it off.
# Takes effect on the next Wi-Fi reconnect or reboot.
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/10-s10-wifi-powersave-off.conf <<'EOF'
[connection]
wifi.powersave = 2
EOF

echo "input booster: $(cat /sys/class/input_booster/enable_event)"
for p in /sys/devices/system/cpu/cpufreq/policy*; do
	echo "$(basename $p): $(cat $p/scaling_governor) up=$(cat $p/schedutil/up_rate_limit_us) down=$(cat $p/schedutil/down_rate_limit_us)"
done
echo "== done"
