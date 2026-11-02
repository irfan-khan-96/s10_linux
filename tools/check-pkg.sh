#!/bin/bash
# Syntax-check the package sources in pkg/.
cd /mnt/c/Users/irfan/Desktop/s10-postmarketos/pkg
for f in s10-osk s10-menu s10-idle-blank s10-splash s10-touch-absfix; do
	[ -e "$f" ] && python3 -c "import ast, sys; ast.parse(open(sys.argv[1]).read())" "$f" && echo "py ok $f"
done
for f in s10-status s10-term s10-osk-start s10-terminal.post-install s10-terminal.post-upgrade *.start; do
	sh -n "$f" && echo "sh ok $f"
done
