#!/bin/bash
export PATH=$HOME/.local/bin:$PATH
pmbootstrap config sudo_timer True </dev/null
echo "sudo_timer = $(pmbootstrap config sudo_timer </dev/null)"
