#!/bin/bash
C=$(ls ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream/config-*.aarch64)
echo "== pstore/panic config"
grep -E '^CONFIG_(PSTORE[A-Z_]*|PANIC_TIMEOUT|DEVTMPFS[A-Z_]*|CMDLINE[A-Z_]*|USB_CONFIGFS[A-Z_]*|USB_G_ANDROID|RD_GZIP|RD_ZSTD|RD_LZ4|BLK_DEV_INITRD|SEC_DEBUG|DEBUG_SNAPSHOT[A-Z_]*)=' "$C"
echo "== boot.img header"
~/.venvs/s10tools/bin/python - <<'EOF'
import struct
d=open("/home/khan/s10-odin/boot.img","rb").read(4096)
magic=d[:8]; ks,ka,rs,ra,ss,sa,ta,ps,hv,osv=struct.unpack("<10I",d[8:48])
name=d[48:64].rstrip(b"\0"); cmd=d[64:576].rstrip(b"\0"); extra=d[608:1632].rstrip(b"\0")
print(magic, "hdr_v",hv,"page",ps,"kernel",ks,hex(ka),"ramdisk",rs,hex(ra),"tags",hex(ta))
print("os_version raw",hex(osv)); print("cmdline:",cmd); print("extra:",extra)
EOF
echo "== initramfs compression"; head -c 4 ~/.local/var/pmbootstrap/chroot_rootfs_samsung-beyond1lte-downstream/boot/initramfs 2>/dev/null | xxd
