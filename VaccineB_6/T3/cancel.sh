#! /bin/bash
for jf in jobID_sim*; do
m=`echo $jf | cut -d_ -f2`
echo $m
for j in `awk '{a[NR]=$0}\
END{for(i=NR;i>0;i--)print a[i]}' $jf`; do
curl -s http://$m.intlab.soka.ac.jp/stopJob?job=$j
echo -n " "$j
sleep 1
done
echo ""
done
