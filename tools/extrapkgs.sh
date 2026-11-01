#!/bin/bash
export PATH=$HOME/.local/bin:$PATH
cur=$(pmbootstrap config extra_packages </dev/null)
case ",$cur," in *,s10-terminal,*) ;; *) pmbootstrap config extra_packages "${cur:+$cur,}s10-terminal" </dev/null ;; esac
echo "extra_packages = $(pmbootstrap config extra_packages </dev/null)"
