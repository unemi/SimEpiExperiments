#! /bin/sh
i=40
for job in `cat jobID`; do \
fn=`printf "MyResult%02d\n" $i`
curl -O -J -s http://simepi2.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if [ -f ${fn}.zip ]; then \
  unzip -q $fn
  rm ${fn}.zip
fi
i=$(($i+5))
done