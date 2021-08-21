#! /bin/bash
for rd in 088 081; do
 for vd in 136 106; do
  cd ../V1_${rd}_$vd
  for pd in 06 04 02; do cd $pd
   if [ ! -f jobID_simepi ]; then
    n=100
    while [ $n -gt 40 ]; do n=0
      for m in simepiM0{0..7} simepi2 simepi; do
        isDead=true
        while $isDead; do
        x=`curl -s http://$m.intlab.soka.ac.jp/getJobQueueStatus | cut -d: -f2 | cut -d\} -f1`
        if [ `echo $x | awk '{print NF}'` -eq 1 ]; then isDead=false
        else sleep 60; fi
        done
        if [ $n -lt $x ]; then n=$x; fi
      done
      if [ $n -gt 40 ]; then echo `date` $n; sleep 900; fi
    done
    echo `date` $rd $pd
    ../../R/Vsubmit.sh > submit.log
    sleep 900
   fi
   cd ..
  done
 done
done
