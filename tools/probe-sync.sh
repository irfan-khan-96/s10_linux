#!/bin/sh
# Run on the phone: firewall rules and what the syncthing package would install.
cat /etc/local.d/10-firewall.start
apk search -x syncthing syncthing-openrc 2>&1
apk info -L syncthing-openrc 2>/dev/null
