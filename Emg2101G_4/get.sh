#! /bin/sh
for m in dhcp06; do \
i=0
if [ -f jobID_$m ]; then \
for job in `cat jobID_$m`; do \
fn=`printf "R_${m}_%02d\n" $i`
curl -O -J -s http://$m.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if [ -f ${fn}.zip ]; then \
  unzip -q $fn
  rm ${fn}.zip
  (cd $fn; echo *.csv | awk '{printf "'$fn' %d\n",NF}')
fi
i=$(($i+1))
done
fi
done
