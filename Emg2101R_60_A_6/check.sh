#! /bin/bash
LANG=C date
for jj in jobID_*; do \
m=`echo $jj | cut -d_ -f2`
echo $m
for j in `awk 'NR<3{j[NR]=$1}\
END{printf "%s %s\n",j[1],j[2]}' $jj`; do \
echo -n $j" "
curl http://$m.intlab.soka.ac.jp/getJobStatus?job=$j
echo ""
done
done
