#!/bin/sh
# Harden the S10 postmarketOS server: firewall (legacy iptables, as this 4.14
# kernel has no nftables) and key-only SSH. Run once with: sudo sh ~/harden.sh
# The firewall reverts itself after 120 s unless /tmp/fw-confirm exists.
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== installing iptables"
# the default iptables uses the nftables backend, which this kernel lacks
apk add -q iptables iptables-legacy
IPT=$(command -v iptables-legacy) || { echo "iptables-legacy missing"; exit 1; }
IP6T=$(command -v ip6tables-legacy) || { echo "ip6tables-legacy missing"; exit 1; }
$IPT -S INPUT >/dev/null || { echo "legacy iptables does not work on this kernel"; exit 1; }
echo "using $IPT and $IP6T"

echo "== writing /etc/local.d/10-firewall.start"
mkdir -p /etc/local.d
cat > /etc/local.d/10-firewall.start <<EOF
#!/bin/sh
# Allow SSH from the home LAN and the USB link only; drop all other inbound.
IPT=$IPT
IP6T=$IP6T
for t in \$IPT \$IP6T; do
	\$t -F INPUT; \$t -F FORWARD
	\$t -P INPUT DROP; \$t -P FORWARD DROP; \$t -P OUTPUT ACCEPT
	\$t -A INPUT -i lo -j ACCEPT
	\$t -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
	\$t -A INPUT -m conntrack --ctstate INVALID -j DROP
	\$t -A INPUT -i rndis0 -p tcp --dport 22 -j ACCEPT
done
\$IPT -A INPUT -p icmp -j ACCEPT
\$IPT -A INPUT -i wlan0 -s 192.168.178.0/24 -p tcp --dport 22 -j ACCEPT
\$IPT -A INPUT -i wlan0 -p udp --sport 67 --dport 68 -j ACCEPT
\$IPT -A INPUT -i rndis0 -p udp --dport 67 -j ACCEPT
\$IP6T -A INPUT -p ipv6-icmp -j ACCEPT
\$IP6T -A INPUT -s fe80::/10 -p udp --dport 546 -j ACCEPT
\$IP6T -A INPUT -i wlan0 -s fe80::/10 -p tcp --dport 22 -j ACCEPT
EOF
chmod 755 /etc/local.d/10-firewall.start
rc-update add local default >/dev/null 2>&1 || true

echo "== applying firewall (auto-revert in 120 s unless confirmed)"
rm -f /tmp/fw-confirm /tmp/fw-reverted
# start the revert timer first, so it runs even if a rule fails
setsid sh -c "sleep 120; if [ ! -f /tmp/fw-confirm ]; then
	for t in $IPT $IP6T; do \$t -P INPUT ACCEPT; \$t -P FORWARD ACCEPT; \$t -F INPUT; \$t -F FORWARD; done
	mv /etc/local.d/10-firewall.start /etc/local.d/10-firewall.start.reverted
	echo 'firewall reverted (not confirmed)' > /tmp/fw-reverted
fi" >/dev/null 2>&1 < /dev/null &
/etc/local.d/10-firewall.start || echo "WARNING: some firewall rules failed"

echo "== SSH: key-only login"
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
AllowUsers farmer
MaxAuthTries 3
EOF
SSHD=$(command -v sshd.pam || command -v sshd)
$SSHD -t && rc-service sshd reload
echo "== done; firewall active, waiting for confirmation"
$IPT -S INPUT | head -20
