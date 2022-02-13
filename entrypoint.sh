#!/bin/sh
set -e

ipset -R <chnroute.ipset
ipset -R <chnroute6.ipset
nohup crond -l 2 -f >/dev/null 2>&1 &
chinadns-ng -b 0.0.0.0 -l ${PORT} -c ${CHINA_DNS} -t ${TRUCT_DNS} -g /etc/chinadns-ng/gfwlist.txt -m /etc/chinadns-ng/chnlist.txt -o 3 -r