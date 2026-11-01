#!/bin/sh
# Sxmo polish for the S10: basic apps, Samba share (home network only),
# DHCP on the USB link. Run with: sudo sh ~/polish.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== 1/4 apps: file manager, text editor, browser, system monitor"
apk add -q pcmanfm mousepad netsurf htop nano

echo "== 2/4 Samba share \\\\192.168.178.32\\s10 -> /home/farmer/share"
apk add -q samba samba-server-openrc 2>/dev/null || apk add -q samba
install -d -o farmer -g farmer /home/farmer/share
[ -f /etc/samba/smb.conf.orig ] || cp /etc/samba/smb.conf /etc/samba/smb.conf.orig 2>/dev/null || true
cat > /etc/samba/smb.conf <<'EOF'
[global]
	server role = standalone server
	workgroup = WORKGROUP
	server string = Galaxy S10
	# home network and loopback only; SMB2+ only, no NetBIOS
	interfaces = lo wlan0
	bind interfaces only = yes
	hosts allow = 127. 192.168.178.
	server min protocol = SMB2_10
	disable netbios = yes
	smb ports = 445
	map to guest = never
	restrict anonymous = 2
	load printers = no
	printing = bsd
	printcap name = /dev/null

[s10]
	path = /home/farmer/share
	valid users = farmer
	read only = no
	browseable = yes
	create mask = 0644
	directory mask = 0755
EOF
testparm -s >/dev/null 2>&1 && echo "smb.conf OK"
# only smbd is needed (NetBIOS is off)
[ -f /etc/conf.d/samba ] && sed -i 's/^daemon_list=.*/daemon_list="smbd"/' /etc/conf.d/samba
rc-update add samba default >/dev/null
rc-service samba restart >/dev/null

echo "== 3/4 firewall: allow SMB (TCP 445) from the home network only"
FW=/etc/local.d/10-firewall.start
grep -q 'dport 445' $FW || sed -i 's|^\$IPT -A INPUT -i wlan0 -s 192.168.178.0/24 -p tcp --dport 22 -j ACCEPT$|&\n$IPT -A INPUT -i wlan0 -s 192.168.178.0/24 -p tcp --dport 445 -j ACCEPT|' $FW
grep -q 'dport 445' $FW || { echo "could not add the firewall rule"; exit 1; }
$FW

echo "== 4/4 DHCP on the USB link (so Windows gets 172.16.42.2)"
cat > /etc/local.d/30-usb-dhcp.start <<'EOF'
#!/bin/sh
# The initramfs DHCP server stops at switch_root; run one for the booted system.
ip addr show rndis0 2>/dev/null | grep -q 172.16.42.1 || ip addr add 172.16.42.1/16 dev rndis0
ip link set rndis0 up
pidof unudhcpd >/dev/null || setsid unudhcpd -i rndis0 -s 172.16.42.1 -c 172.16.42.2 >/dev/null 2>&1 < /dev/null &
EOF
chmod 755 /etc/local.d/30-usb-dhcp.start
/etc/local.d/30-usb-dhcp.start

echo
echo "== last step: choose a password for the network share (can differ from the login password)"
smbpasswd -a farmer
echo "== done. Open \\\\192.168.178.32\\s10 in Windows Explorer and log in as farmer."
