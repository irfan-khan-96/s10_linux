#!/bin/bash
set -e
cd ~/s10-kernel
top=$(ls -d android_kernel_samsung_exynos9820-*)
f=drivers/video/fbdev/exynos/dpu20/decon_core.c
rm -rf a b; mkdir -p a/$(dirname $f) b/$(dirname $f)
cp $top/$f a/$f
python3 - "$top/$f" "b/$f" <<'EOF'
import sys
s = open(sys.argv[1]).read()
old = """	if (decon->dt.out_type == DECON_OUT_DSI) {
		decon_hiber_block_exit(decon);
		ret = decon_update_pwr_state(decon, DISP_PWR_OFF);
		if (ret)
			decon_err("%s: decon%d failed to set DISP_PWR_OFF, ret %d\\n",
					__func__, decon->id, ret);
		decon_hiber_unblock(decon);
	}
"""
new = """	/*
	 * Android keeps /dev/fb0 open in one process for its whole lifetime, so
	 * powering the panel off on every release is harmless there. On Linux
	 * many programs open and close the framebuffer (X, fbset, tests), and
	 * each close would turn the screen off. Leave panel power to explicit
	 * FBIOBLANK requests (screen blanking) instead.
	 */
"""
assert s.count(old) == 1, "release block not found"
s = s.replace(old, new)
# 'ret' is now unused in decon_release; keep the build warning-free
s = s.replace("""	struct decon_device *decon = win->decon;
	int ret;

	decon_info("%s + : %d\\n", __func__, decon->id);
#if defined(CONFIG_SEC_DISPLAYPORT_LOGGER)
	if (decon->dt.out_type == DECON_OUT_DP)
		dp_logger_print("decon release\\n");""", """	struct decon_device *decon = win->decon;

	decon_info("%s + : %d\\n", __func__, decon->id);
#if defined(CONFIG_SEC_DISPLAYPORT_LOGGER)
	if (decon->dt.out_type == DECON_OUT_DP)
		dp_logger_print("decon release\\n");""", 1)
open(sys.argv[2], "w").write(s)
EOF
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/linux-samsung-beyond1lte-downstream
{
  echo "decon: don't power off the panel when /dev/fb0 is closed"
  echo
  echo "Samsung's decon_release() turns the DSI panel off on every close of the"
  echo "framebuffer, which leaves the screen black on Linux. Only blank on FBIOBLANK."
  echo
  diff -u a/$f b/$f || true
} > $P/decon-keep-panel-on-release.patch
cd $P
python3 - <<'EOF'
p = "APKBUILD"; s = open(p).read()
if "decon-keep-panel-on-release.patch" not in s:
    s = s.replace("\tloop-dio-blockdev-bsize.patch\n", "\tloop-dio-blockdev-bsize.patch\n\tdecon-keep-panel-on-release.patch\n", 1)
    s = s.replace("pkgrel=3\n", "pkgrel=4\n", 1)
    open(p, "w").write(s)
EOF
h=$(sha512sum decon-keep-panel-on-release.patch | cut -d' ' -f1)
python3 - "$h" <<'EOF'
import sys
h = sys.argv[1]; p = "APKBUILD"; line = f"{h}  decon-keep-panel-on-release.patch\n"
s = open(p).read()
if line not in s:
    head, sums = s.split('sha512sums="\n', 1); body, tail = sums.split('"\n', 1)
    s = head + 'sha512sums="\n' + body + line + '"\n' + tail; open(p, "w").write(s)
EOF
grep -c '^[-+]' decon-keep-panel-on-release.patch
grep -nE '^pkgrel|decon-keep' APKBUILD
git add decon-keep-panel-on-release.patch
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "linux-samsung-beyond1lte-downstream: keep panel on when fb0 is closed"
git log -1 --oneline
