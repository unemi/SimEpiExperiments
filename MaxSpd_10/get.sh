#! /bin/sh
i=1
for job in `cat jobID_simepi2`; do \
fn=`printf "MyResult_4_2_%02d\n" $i`
curl -O -J -s http://simepi2.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if [ -f ${fn}.zip ]; then \
  unzip -q $fn
  rm ${fn}.zip
fi
i=$(($i+1))
done