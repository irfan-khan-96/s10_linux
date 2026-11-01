#!/bin/bash
set -e
mkdir -p ~/.ssh && chmod 700 ~/.ssh
install -m 600 /mnt/c/Users/irfan/.ssh/s10_phone ~/.ssh/s10_phone
install -m 644 /mnt/c/Users/irfan/.ssh/s10_phone.pub ~/.ssh/s10_phone.pub
touch ~/.ssh/config && chmod 600 ~/.ssh/config
grep -q '^Host s10$' ~/.ssh/config || printf '\nHost s10\n    HostName 192.168.178.32\n    User farmer\n    IdentityFile ~/.ssh/s10_phone\n    IdentitiesOnly yes\n' >> ~/.ssh/config
ssh -o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new s10 'echo WSL_S10_OK'