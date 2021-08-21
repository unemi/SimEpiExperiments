#! /bin/sh
for m in simepi; do \
i=4
for job in `tail -2 jobID_$m`; do \
fn=`printf "Rx_${m}_%02d\n" $i`
curl -O -J -s http://$m.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if [ -f ${fn}.zip ]; then \
  unzip -q $fn
  rm ${fn}.zip
  (cd $fn; echo *.csv | awk '{printf "'$fn' %d\n",NF}')
fi
i=$(($i+4))
done
done
