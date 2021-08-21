#! /bin/bash
LANG=C date
for jj in jobID_*; do \
m=`echo $jj | cut -d_ -f2`
n=`curl http://$m.intlab.soka.ac.jp/getJobQueueStatus -s |\
  awk -F: '{split($2,a,"}");print a[1]}'`
if [ "$n" == ""  ]; then echo $'\e[5m'"$m does not work."$'\e[0m'
else
echo $m" "$n
for j in `awk '{j[NR]=$1}\
END{k=NR-'$n';if(k<1)k++;else if(k>=NR)k--;printf "%s %s\n",j[k],j[k+1]}' jobID_$m`; do \
  echo -n $j" "
curl http://$m.intlab.soka.ac.jp/getJobStatus?job=$j
echo ""
done
fi
done
