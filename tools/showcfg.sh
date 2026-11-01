#!/bin/bash
cd /mnt/c/Users/irfan/Desktop/s10-postmarketos/phone-config
for f in etc/local.d/*.start etc/conf.d/unudhcpd.rndis0 etc/NetworkManager/conf.d/* etc/ssh/sshd_config.d/10-hardening.conf etc/udev/rules.d/90-s10-touch-absfix.rules home/farmer/.fbtermrc home/farmer/.s10-term.sh; do
  echo "===== $f"; cat "$f"
done
grep -n '^tty1' etc/inittab
