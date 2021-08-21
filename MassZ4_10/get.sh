#! /bin/sh
i=15
for job in `cat jobID_simepi`; do \
fn=`printf "MyResult_%02d\n" $i`
curl -O -J -s http://simepi.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if [ -f ${fn}.zip ]; then \
  unzip -q $fn
  rm ${fn}.zip
fi
i=$(($i+5))
done