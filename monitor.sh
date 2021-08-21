#! /bin/bash
LANG=C
if [ "$1" = "" ]; then d=(.); else d=($*); fi
sec1=`date +%s`
for dd in ${d[@]}; do
  if [ -d $dd ]; then
    pushd $dd > /dev/null
    slpTm=300
    if [ -f `echo jobID_simepi* | cut -d\  -f1` ]; then
      for jbf in jobID_simepi*; do
        m=`echo $jbf | cut -d_ -f2`
        i=1
        for j in `cat $jbf`; do
          a=0
          while [ $a = 0 ]; do
            curl -s http://$m.intlab.soka.ac.jp/getJobStatus?job=$j > /tmp/m$$
            echo "" >> /tmp/m$$
            s=(`awk -F: '{split(substr($2,2,99),a,"]");split($4,b,"}");\
              printf "%s %s",(a[1]=="")?"-":a[1],b[1]}' /tmp/m$$`)
            rm -f /tmp/m$$
            if [ "${s[0]}" != "-" -o "${s[1]}" -gt 0 ]
              then echo `date +%H:%M:%S` $dd $m $i ${s[0]}; sleep $slpTm
              else a=1
            fi
          done
          i=$((i+1))
        done
        echo `date +%H:%M:%S` $dd $m "completed."
        slpTm=120
      done
      sec2=`date +%s`
      if [ $((sec2-sec1)) -gt 15 ]; then
        if [ "$dd" = "." ]; then dir=`pwd | awk -F/ '{print $NF}'`; else dir=$dd; fi
        say -v Alex "Your SimEpidemic batch jobs in $dir have finished." &
      fi
      sec1=$sec2
    fi
    popd > /dev/null
  fi
done