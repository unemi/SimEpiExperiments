#! /bin/sh
for jj in jobID_*; do
m=`echo $jj | cut -d_ -f2`
awk '{a[NR]=$0}\
END{for(i=NR;i>0;i--)print a[i]}' $jj > xx
for job in `cat xx`; do
curl http://$m.intlab.soka.ac.jp/stopJob?job=$job
done
echo " "$m
done
rm xx