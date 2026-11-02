#!/bin/sh
# Run on the phone: write the s10 palette straight to fbterm's terminal (bypassing tmux), redraw.
palette='0;0;0;0 1;204;102;102 2;181;189;104 3;240;198;116 4;129;162;190 5;178;148;187
6;138;190;183 7;197;200;198 8;102;102;110 9;213;78;83 10;185;202;74 11;231;197;71
12;122;166;218 13;195;151;216 14;112;192;177 15;234;234;234'
tty=$(tmux list-clients -F '#{client_tty}' | head -1)
for c in $palette; do printf "\033[3;$c}" > "$tty"; done
tmux refresh-client
infocmp fbterm 2>/dev/null | tr ',' '\n' | grep -E '^\s*(oc|op|setaf)='
