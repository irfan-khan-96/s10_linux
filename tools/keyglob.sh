#!/bin/bash
export PATH=$HOME/.local/bin:$PATH
pmbootstrap config ssh_key_glob "~/.ssh/s10_phone.pub" </dev/null
echo "ssh_key_glob = $(pmbootstrap config ssh_key_glob </dev/null)"
cp ~/.config/pmbootstrap_v3.cfg /mnt/c/Users/irfan/Desktop/s10-postmarketos/pmbootstrap_v3.cfg
