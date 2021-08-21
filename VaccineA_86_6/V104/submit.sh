#! /bin/bash
st=`pwd | awk -F_ '{split($3,a,"V");printf "E%03d_%s\n",$2,a[2]}'`
tl=256	# 256 = Aug. 31
pf=".intlab.soka.ac.jp"
for m in simepi simepi2; do
rm -f jobID_$m
case $m in
  simepi) nn=12; ;;
  simepi2) nn=8; ;;
  *) nn=2; ;;
esac
for ((x=2;x<=10;x+=2)); do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"loadState":"$st",
"params":{"vaccinePerformRate":$x},
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
