#!/bin/bash
set -e
cd ~/s10-kernel
top=$(ls -d android_kernel_samsung_exynos9820-*)
mkdir -p a/drivers/block b/drivers/block
cp loop.c.orig a/drivers/block/loop.c
python3 - <<'EOF'
s = open("loop.c.orig").read()
old = """	if (inode->i_sb->s_bdev) {
		sb_bsize = bdev_logical_block_size(inode->i_sb->s_bdev);
		dio_align = sb_bsize - 1;
	}
"""
new = old + """	/*
	 * A block device backing file sits on the bdev pseudo filesystem, which
	 * has no s_bdev, so use the device's own logical block size. Otherwise
	 * direct I/O gets enabled on 4K-sector UFS behind a 512-byte loop device
	 * and every unaligned read (e.g. ext4 superblock probing) fails.
	 */
	if (S_ISBLK(inode->i_mode)) {
		sb_bsize = bdev_logical_block_size(I_BDEV(inode));
		dio_align = sb_bsize - 1;
	}
"""
assert s.count(old) == 1
open("b/drivers/block/loop.c", "w").write(s.replace(old, new))
EOF
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream
{
  echo "loop: use backing block device's logical block size for direct I/O"
  echo
  echo "Without this, direct I/O is enabled for a 512-byte loop device on top of"
  echo "4K-sector UFS, and postmarketOS's 'losetup --direct-io=on' subpartitions"
  echo "cannot be mounted ('unable to read superblock')."
  echo
  diff -u a/drivers/block/loop.c b/drivers/block/loop.c || true
} > $P/loop-dio-blockdev-bsize.patch
cat $P/loop-dio-blockdev-bsize.patch
cd $P
python3 - <<'EOF'
p = "APKBUILD"; s = open(p).read()
if "loop-dio-blockdev-bsize.patch" not in s:
    s = s.replace("\tselinux_include_generated_headers.patch\n",
                  "\tselinux_include_generated_headers.patch\n\tloop-dio-blockdev-bsize.patch\n", 1)
    s = s.replace("pkgrel=1\n", "pkgrel=2\n", 1)
    open(p, "w").write(s)
EOF
h=$(sha512sum loop-dio-blockdev-bsize.patch | cut -d' ' -f1)
grep -q '  loop-dio-blockdev-bsize.patch$' APKBUILD || sed -i "s/^\"$/$h  loop-dio-blockdev-bsize.patch\n\"/" APKBUILD
grep -nE '^pkgrel|\.patch' APKBUILD
git add loop-dio-blockdev-bsize.patch
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "linux-samsung-beyond1lte-downstream: fix loop direct I/O on 4K block devices"
git log -1 --oneline
