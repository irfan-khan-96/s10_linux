#!/bin/bash
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/firmware-samsung-beyond1lte
if ! grep -q 'etc/wifi' APKBUILD; then
python3 - <<'EOF'
p="APKBUILD"; s=open(p).read()
old='''			"$pkgdir/lib/firmware/postmarketos/$file"
	done
}'''
new='''			"$pkgdir/lib/firmware/postmarketos/$file"
	done

	# bcmdhd loads firmware from CONFIG_BCMDHD_FW_PATH (/etc/wifi/...)
	mkdir -p "$pkgdir"/etc
	ln -s /lib/firmware/postmarketos "$pkgdir"/etc/wifi
}'''
assert old in s; s=s.replace(old,new).replace("pkgrel=0","pkgrel=1",1); open(p,"w").write(s)
EOF
fi
sed -n '/^package()/,/^}/p' APKBUILD; grep -n '^pkgrel' APKBUILD
git -c user.name="khan" -c user.email="khan@localhost" commit -qam "firmware-samsung-beyond1lte: link /etc/wifi to firmware dir"
git log --oneline -4
