#!/bin/sh
# USB networking on the S10 uses rndis0, but postmarketOS starts its DHCP
# server for usb0. Run it for rndis0 instead. Run with: sudo sh ~/usbfix.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
rc-service unudhcpd.usb0 stop >/dev/null 2>&1 || true
rc-update del unudhcpd.usb0 boot >/dev/null 2>&1 || true
ln -sf /etc/init.d/unudhcpd /etc/init.d/unudhcpd.rndis0
echo 'UNUDHCPD_SERVER="172.16.42.1"' > /etc/conf.d/unudhcpd.rndis0
rc-update add unudhcpd.rndis0 default >/dev/null
# keep only the address part of the earlier helper; the service now does DHCP
cat > /etc/local.d/30-usb-dhcp.start <<'EOF'
#!/bin/sh
# rndis0 normally keeps 172.16.42.1 from the initramfs; make sure it has it.
ip addr show rndis0 2>/dev/null | grep -q 172.16.42.1 || ip addr add 172.16.42.1/16 dev rndis0
ip link set rndis0 up
EOF
/etc/local.d/30-usb-dhcp.start
rc-service unudhcpd.rndis0 start
pgrep -a unudhcpd
echo "== done"
