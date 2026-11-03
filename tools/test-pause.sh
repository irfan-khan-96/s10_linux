#!/bin/sh
# Run on the phone as farmer: does tmux leave htop paused with SIGSTOP vs SIGTTOU?
p=$(pgrep -x htop | head -1)
kill -STOP $p; sleep 1; echo "after STOP: $(awk '{print $3}' /proc/$p/stat)"
kill -CONT $p; sleep 1
kill -TTOU $p; sleep 1; echo "after TTOU: $(awk '{print $3}' /proc/$p/stat)"
kill -CONT $p; sleep 1; echo "after CONT: $(awk '{print $3}' /proc/$p/stat)"
echo "refresher process name: $(cat /proc/$(pgrep -f msm-fb-refresher | head -1)/comm)"
