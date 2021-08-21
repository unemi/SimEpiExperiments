#! /bin/bash
if [ -z "$2" ]; then echo "usage: $0 <host name> <data file>"; exit; fi
for df in $2_*; do
if [ ! -z "`jq type < $df`" ]; then
echo -n "job=" | cat - $df | curl http://$1/submitJob -s -d @-
echo ""
fi
done