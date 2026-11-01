#!/bin/sh
# Run on the phone: display-related kernel messages (state changes, errors) since the log was last cleared.
echo "s10-blanked: $(cat /run/s10-blanked)  uptime: $(cut -d' ' -f1 /proc/uptime)"
dmesg | grep -E 'dsim_enable|dsim_disable|decon_enable|decon_disable|decon_blank|panel_sleep|panel_fb_notifier|Display ON|panel_state|esd|ESD|underrun|timeout|fail' | grep -v -E 'ssp|SSP|sec_ts|dhd|wl_' | tail -40
