#! /bin/bash
finished=0
while [ $finished -eq 0 ]; do finished=1; sleep 0.2
for m in simepiM0{0..7} simepi2 simepi; do
if [ -f $1_${m}_0 ]; then
  nj=`echo $1_${m}_* | awk '{print NF}'`
  if [ -f jobID_$m -a `awk 'END{print NR}' jobID_$m` -ge $nj ]; then
    echo $m $nj
    rm -f $1_${m}_*
  else finished=0
  fi
fi
done
done
LANG=C date
