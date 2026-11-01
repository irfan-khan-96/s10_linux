#!/bin/bash
I=$(ls /sys/class/net | grep '^enx' | head -1)
echo "iface=$I"
ip -br a show $I; echo "carrier=$(cat /sys/class/net/$I/carrier 2>&1) oper=$(cat /sys/class/net/$I/operstate)"
echo "driver: $(basename $(readlink /sys/class/net/$I/device/driver) 2>/dev/null)"
ip neigh show dev $I
echo "== usb"; for d in /sys/bus/usb/devices/*; do [ -f $d/idVendor ] && echo "$(basename $d) $(cat $d/idVendor):$(cat $d/idProduct) $(cat $d/product 2>/dev/null) cfg=$(cat $d/bConfigurationValue 2>/dev/null)"; done
for i in /sys/bus/usb/devices/*:*; do [ -f $i/bInterfaceClass ] && echo "$(basename $i) class=$(cat $i/bInterfaceClass)/$(cat $i/bInterfaceSubClass) drv=$(basename $(readlink $i/driver) 2>/dev/null) $(cat $i/interface 2>/dev/null)"; done
echo "== rx/tx"; cat /sys/class/net/$I/statistics/{rx_packets,tx_packets}
