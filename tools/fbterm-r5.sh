#!/bin/bash
# fbterm r5: place and size each glyph by its rendered bitmap (bitmap_left/bitmap_top,
# bitmap.width/rows) instead of the outline metrics. With anti-aliasing off the monochrome
# bitmap can be a pixel wider or offset from the metrics, and fbterm clipped it to them:
# thin or cut strokes. Builds glyph-bitmap.patch against the original source (local patches
# apply before Debian's), checks the order, updates the APKBUILD and commits.
set -e
T=/mnt/c/Users/irfan/Desktop/s10-postmarketos/tools
P=~/.local/var/pmbootstrap/cache_git/pmaports/main/fbterm
D=~/.local/var/pmbootstrap/cache_distfiles
rm -rf /tmp/fbt5 && mkdir /tmp/fbt5 && cd /tmp/fbt5
tar xzf $D/fbterm_1.7.orig.tar.gz
cp -r fbterm-1.7 orig
python3 - <<'EOF'
p = "fbterm-1.7/src/font.cpp"
s = open(p).read()
old = """	glyph->left = face->glyph->metrics.horiBearingX >> 6;
	glyph->top = mHeight - 1 + (face->size->metrics.descender >> 6) - (face->glyph->metrics.horiBearingY >> 6);
	glyph->width = face->glyph->metrics.width >> 6;
	glyph->height = face->glyph->metrics.height >> 6;"""
new = """	// the rendered bitmap's own offset and size (the outline metrics can differ by a pixel,
	// most of all for monochrome glyphs, and clipping to them cut strokes)
	glyph->left = face->glyph->bitmap_left;
	glyph->top = mHeight - 1 + (face->size->metrics.descender >> 6) - face->glyph->bitmap_top;
	glyph->width = w;
	glyph->height = h;"""
assert s.count(old) == 1
open(p, "w").write(s.replace(old, new))
EOF
diff -u orig/src/font.cpp fbterm-1.7/src/font.cpp | sed -e 's#^--- orig/#--- a/#' -e 's#^+++ fbterm-1.7/#+++ b/#' > "$P/glyph-bitmap.patch" || true
head -3 "$P/glyph-bitmap.patch"
cd "$P"
python3 - <<'EOF'
import re
s = open("APKBUILD").read()
s = re.sub(r"^pkgrel=\d+$", "pkgrel=5", s, flags=re.M)
if "glyph-bitmap.patch" not in s:
    s = s.replace("\tscanlines.patch\n\t\"", "\tscanlines.patch\n\tglyph-bitmap.patch\n\t\"")
    s = s.rstrip('"\n') + "\nX  glyph-bitmap.patch\n\"\n"
open("APKBUILD", "w").write(s)
EOF
python3 "$T/resum.py" . | tail -1
sed -i 's/palette-refresh scanlines; do/palette-refresh scanlines glyph-bitmap; do/' "$T/fbterm-order-test.sh"
bash "$T/fbterm-order-test.sh" 2>&1 | grep -E '^ok|debian' || true
cd ../..
git add -A main/fbterm
git -c user.name=khan -c user.email=khan@localhost commit -q -m "fbterm r5: place glyphs by their rendered bitmap (sharp monochrome text)" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git log -1 --oneline
