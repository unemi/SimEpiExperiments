#! /bin/sh
xx="3 7 8"
for m in simepi ; do \
i=1
for job in `cat jobID_$m`; do \
fn=`echo $xx | awk '{printf "R_'$m'_%02d\n",$'$i'}'`
echo $fn 
curl -O -J -s http://$m.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if [ -f ${fn}.zip ]; then \
  unzip -q $fn
  rm ${fn}.zip
  (cd $fn; echo *.csv | awk '{printf "'$fn' %d\n",NF}')
fi
i=$(($i+1))
done
done
