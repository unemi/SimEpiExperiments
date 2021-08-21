#! /bin/bash
st=`pwd | cut -d_ -f2 | awk '{printf "E%03d_104\n",$1}'`
tl=`pwd | awk -F/ '{print $NF}'`
pf=".intlab.soka.ac.jp"
for m in simepi simepi2; do
rm -f jobID_$m
case $m in
  simepi) nn=12; ;;
  simepi2) nn=8; ;;
  *) nn=2; ;;
esac
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"loadState":"$st",
"params":{"gatheringFrequency":20},
"out":["saveState",
"asymptomatic","symptomatic","recovered","died","vaccinated",
"dailyTests","dailyTestPositive","dailyTestNegative",
"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $mb `cat /tmp/s$$`
done
rm /tmp/s$$
