#! /bin/bash
LANG=C date
if [ `echo jobID_* | awk '{print (NF==1 && length($0)==7)?0:1}'` -eq 0 ]
then echo "jobID could not be found."; exit; fi
for j in jobID_*; do
m=`echo $j | cut -d_ -f2`
n=`awk 'END{print NR}' $j`
if [ $n -eq 0 ]; then
  echo $j is empty.
else
  if [ $# -gt 0 ]; then
    if [ $1 -gt 0 -a $1 -le $n ]; then n=$1; fi
  fi
  echo -n $m" "
  curl -s http://$m.intlab.soka.ac.jp/getJobStatus?job=`awk 'NR=='$n'{print}' $j`
  echo ""
fi
done
