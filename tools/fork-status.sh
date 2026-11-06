#!/bin/bash
# Show the fork's branch, its upstream base, our commits and what upstream changed since.
cd ~/.local/var/pmbootstrap/cache_git/pmaports
git status -sb | head -3
git remote -v | head -2
git fetch -q origin
up=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || echo origin/master)
echo "upstream: $up"
base=$(git merge-base HEAD "$up")
echo "base: $(git log -1 --format='%h %cd %s' --date=short $base)"
echo "ours: $(git rev-list --count $base..HEAD) commits; upstream since base: $(git rev-list --count $base..$up)"
git log --oneline $base..HEAD | cat
echo "--- upstream changes touching paths we also change:"
ours=$(git diff --name-only $base HEAD | sed 's|/[^/]*$||' | sort -u)
for d in $ours; do
	n=$(git rev-list --count $base..$up -- "$d")
	[ "$n" != 0 ] && echo "$d: $n upstream commits"
done
echo "--- upstream changes to device/downstream, main/postmarketos-*, pmbootstrap-relevant:"
git diff --stat $base $up -- device/archived/samsung-beyond1lte-downstream device/downstream main/postmarketos-base* | tail -5
cd ~/pmbootstrap && git log -1 --format='pmbootstrap %h %cd' --date=short && git fetch -q && echo "pmbootstrap behind: $(git rev-list --count HEAD..@{u})"
