#! /bin/bash
LANG=C date
for m in simepi; do \
if [ -f jobID_$m ]; then \
n=`curl http://$m.intlab.soka.ac.jp/getJobQueueStatus -s |\
  awk -F: '{split($2,a,"}");print a[1]}'`
echo $m" "$n
for j in `awk '{j[NR]=$1}\
END{k=NR-'$n';if(k<1)k++;else if(k>=NR)k--;printf "%s %s\n",j[k],j[k+1]}' jobID_$m`; do
echo -n $j" "
curl http://$m.intlab.soka.ac.jp/getJobStatus?job=$j
echo ""
done
fi
done
