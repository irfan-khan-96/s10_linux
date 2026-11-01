#!/bin/bash
set -e
cd ~/s10-kernel
rm -rf a b; mkdir -p a/drivers/block b/drivers/block
cp loop.c.orig a/drivers/block/loop.c
python3 - <<'EOF'
s = open("loop.c.orig").read()
old1 = """	if (inode->i_sb->s_bdev) {
		sb_bsize = bdev_logical_block_size(inode->i_sb->s_bdev);
		dio_align = sb_bsize - 1;
	}
"""
new1 = old1 + """	/*
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
old2 = """	} else {
		use_dio = false;
	}

	if (lo->use_dio == use_dio)
		return;
"""
new2 = """	} else {
		use_dio = false;
	}

	/*
	 * losetup --direct-io opens the backing file with O_DIRECT. If direct
	 * I/O was refused above, buffered lo_read_simple()/lo_write_simple()
	 * would still go through that O_DIRECT file with unaligned sizes, so
	 * drop the flag to really fall back to the page cache.
	 */
	if (!use_dio && (file->f_flags & O_DIRECT)) {
		spin_lock(&file->f_lock);
		file->f_flags &= ~O_DIRECT;
		spin_unlock(&file->f_lock);
	}

	if (lo->use_dio == use_dio)
		return;
"""
assert s.count(old1) == 1 and s.count(old2) == 1
open("b/drivers/block/loop.c", "w").write(s.replace(old1, new1).replace(old2, new2))
EOF
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream
{
  echo "loop: don't use direct I/O that the backing block device can't do"
  echo
  echo "Use the backing block device's logical block size when deciding on"
  echo "direct I/O, and drop O_DIRECT from the backing file when it is refused."
  echo "Without this, postmarketOS's 'losetup --direct-io=on' subpartitions on"
  echo "4K-sector UFS cannot be mounted ('unable to read superblock')."
  echo
  diff -u a/drivers/block/loop.c b/drivers/block/loop.c || true
} > $P/loop-dio-blockdev-bsize.patch
cd $P
sed -i 's/^pkgrel=2$/pkgrel=3/' APKBUILD
h=$(sha512sum loop-dio-blockdev-bsize.patch | cut -d' ' -f1)
sed -i -E "s/^[0-9a-f]{128}  loop-dio-blockdev-bsize.patch$/$h  loop-dio-blockdev-bsize.patch/" APKBUILD
grep -nE '^pkgrel|loop-dio' APKBUILD
grep -c '^+' loop-dio-blockdev-bsize.patch
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "linux-samsung-beyond1lte-downstream: also drop O_DIRECT when loop refuses direct I/O"
git log -1 --oneline
