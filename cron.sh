#!/bin/sh

cd /etc/chinadns-ng/ && ./update-all.sh

cp chnroute.ipset /tmp/chnroute.ipset
cp chnroute6.ipset /tmp/chnroute6.ipset

sed -i '1d' /tmp/chnroute.ipset
sed -i '1d' /tmp/chnroute6.ipset

ipset flush chnroute
ipset -R </tmp/chnroute.ipset
ipset flush chnroute6
ipset -R </tmp/chnroute6.ipset

rm /tmp/chnroute.ipset /tmp/chnroute6.ipset