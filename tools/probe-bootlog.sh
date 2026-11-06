#!/bin/sh
# Run on the phone: touchscreen probe in the boot-time kernel log saved by OpenRC.
ls -l /var/log/dmesg
grep -n -i -E 'sec_ts|4-0048|touch' /var/log/dmesg | grep -v gpio_keys | head -25
echo "--- errors around i2c 4 / regulators"
grep -i -E 'i2c.*4|regulator.*fail|probe.*fail|deferred' /var/log/dmesg | head -15
echo "--- boot reason"
grep -i -E 'reset reason|rst_stat|power on reason|pwron|LOW BATT' /var/log/dmesg | head -5
