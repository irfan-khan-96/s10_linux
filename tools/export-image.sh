#!/bin/bash
# Export the last built image to Desktop\s10-postmarketos\images (asks for the WSL sudo password).
set -e
OUT=/mnt/c/Users/irfan/Desktop/s10-postmarketos/images
cd ~/pmbootstrap && ./pmbootstrap.py export
mkdir -p "$OUT"
cp -L /tmp/postmarketOS-export/boot.img /tmp/postmarketOS-export/samsung-beyond1lte-downstream.img "$OUT"/
(cd "$OUT" && sha256sum boot.img samsung-beyond1lte-downstream.img > SHA256SUMS)
ls -lh "$OUT"
