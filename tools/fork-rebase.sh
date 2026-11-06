#!/bin/bash
# Move the s10-downstream branch onto the latest upstream pmaports (and update pmbootstrap).
# A backup tag keeps the old branch: git reset --hard s10-before-rebase-<date> undoes it.
set -e
cd ~/.local/var/pmbootstrap/cache_git/pmaports
tag=s10-before-rebase-$(date +%Y%m%d)
git tag -f "$tag" HEAD
git fetch -q origin
git -c user.name=khan -c user.email=khan@localhost rebase origin/main
echo "rebased: $(git rev-list --count origin/main..HEAD) commits on $(git log -1 --format='%h %cd' --date=short origin/main); backup tag $tag"
git diff --stat "$tag" HEAD -- device/archived device/downstream/s10-terminal main/fbterm device/testing 2>/dev/null | tail -3
cd ~/pmbootstrap && git pull -q --ff-only && echo "pmbootstrap now $(git log -1 --format='%h %cd' --date=short)"
