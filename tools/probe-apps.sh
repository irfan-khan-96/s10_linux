#!/bin/sh
# Run on the phone: which apps a launcher could offer, and the current tmux config.
for c in nvim wordgrinder htop nmtui nmcli syncthing git epy w3m lynx mc ranger nnn bc python3 ssh mosh; do
	printf '%-12s %s\n' "$c" "$(command -v $c || echo -)"
done
cat /sys/class/power_supply/battery/capacity /sys/class/power_supply/battery/status 2>&1
nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes'
echo "--- tmux.conf"; cat /etc/tmux.conf
echo "--- home"; ls -la ~
