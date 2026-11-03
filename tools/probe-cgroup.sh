#!/bin/sh
# Run on the phone: which cgroup hierarchies exist and whether a freezer is available.
mount | grep cgroup
ls /sys/fs/cgroup/
for d in /sys/fs/cgroup /sys/fs/cgroup/unified /sys/fs/cgroup/freezer; do
	[ -e $d/cgroup.controllers ] && echo "$d controllers: $(cat $d/cgroup.controllers)"
	[ -e $d/freezer.state ] && echo "$d has freezer.state"
	[ -e $d/cgroup.freeze ] && echo "$d has cgroup.freeze"
done
grep -i freezer /proc/cgroups
