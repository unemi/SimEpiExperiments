#! /bin/bash
for i in {1..7}; do \
cd MyResult2_0$i
for f in *.csv; do \
mv $f ../MyResult_$(($i*5+10))/`echo $f | awk -F. '{split($1,a,"_");printf "%s_%d.csv\n",a[1],a[2]+5}'`
done
cd ..
done