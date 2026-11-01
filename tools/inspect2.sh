#!/bin/bash
cd ~/.local/var/pmbootstrap/cache_git/pmaports
f=$(find main -name 'downstreamkernel_prepare*' | head -1); echo "== $f"; cat "$f"
echo "== other downstream kernels' _flavor/_config usage"
grep -h -E '^_flavor=|^_config=' device/downstream/linux-*/APKBUILD | sort | uniq -c | sort -rn | head -8
