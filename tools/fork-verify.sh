#!/bin/bash
# After a rebase: our package directories must be identical to the backup tag, and
# pmbootstrap must still see the right versions.
cd ~/.local/var/pmbootstrap/cache_git/pmaports
tag=$(git tag -l 's10-before-rebase-*' | sort | tail -1)
for d in device/archived/samsung-beyond1lte-downstream device/archived/linux-samsung-beyond1lte-downstream \
         device/archived/firmware-samsung-beyond1lte device/downstream/s10-terminal main/fbterm; do
	[ -d "$d" ] || d=$(dirname "$(git ls-files "*${d##*/}/APKBUILD" | head -1)")
	if git diff --quiet "$tag" HEAD -- "$d"; then echo "same  $d"; else echo "DIFF  $d"; fi
done
git ls-files '*beyond1lte*/APKBUILD' 'main/fbterm/APKBUILD' 'device/downstream/s10-terminal/APKBUILD'
grep -h '^pkgver=\|^pkgrel=' main/postmarketos-base-ui/APKBUILD | tr '\n' ' '; echo "(postmarketos-base-ui now)"
cd ~/pmbootstrap && ./pmbootstrap.py checksum --verify s10-terminal >/dev/null 2>&1 && echo "pmbootstrap reads the tree: ok"
