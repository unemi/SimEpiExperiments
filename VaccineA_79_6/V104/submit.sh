#! /bin/bash
rd=`pwd | cut -d_ -f2`
vd=`pwd | awk -F/ '{print substr($NF,2,3)}'`
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
case $m in
  simepi) nn=6; ;;
  simepi2) nn=4; ;;
  *) nn=5; ;;
esac
rm -f jobID_$m
for ((x=2;x<=10;x+=2)); do
st=`pwd | cut -d_ -f2 | awk '{printf "E%03d_'$vd'",$1}'`
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":256,"n":$nn,
"loadState":"$st",
"params":{"vaccinePerformRate":$x},
"out":["saveState",
"asymptomatic","symptomatic","recovered","died","vaccinated",
"dailyTests","dailyTestPositive","dailyTestNegative",
"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $m $x `cat /tmp/s$$`
done
done
rm /tmp/s$$
