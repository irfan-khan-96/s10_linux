#!/bin/bash
# Grep the S10 downstream kernel source (from pmbootstrap's distfiles): grep-kernel.sh <pattern> [path]
D=~/.local/var/pmbootstrap/cache_distfiles
src=$(ls -d ~/s10-kernel-src/*/ 2>/dev/null | head -1)
if [ -z "$src" ]; then
	tarball=$(ls -S $D/*beyond* $D/*exynos9820* $D/*G973* 2>/dev/null | head -1)
	[ -z "$tarball" ] && tarball=$(ls -S $D/*.tar.gz | head -1)
	echo "unpacking $tarball" >&2
	mkdir -p ~/s10-kernel-src && tar xf "$tarball" -C ~/s10-kernel-src
	src=$(ls -d ~/s10-kernel-src/*/ | head -1)
fi
cd "$src" && grep -rn -E "$1" ${2:-.} --include=*.c --include=*.h | head -20
