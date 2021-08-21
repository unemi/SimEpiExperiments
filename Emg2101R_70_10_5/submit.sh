#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1}'`
gf=`pwd | awk -F_ '{print 2*$2/10}'`
dr=`pwd | awk -F_ '{print 50+$3}'`
pf=".intlab.soka.ac.jp"
for m in simepiM0{5..7}; do \
rm -f jobID_$m
for x in 0 3 7 10 14 21 28 42 60; do \
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":200,"n":2,
"params":{"populationSize":$s,
"fatalityBias":20,
"gatheringFrequency":20,
"incubationBias":20,
"initialInfectedRate":0.12,
"quarantineAsymptomatic":3,
"quarantineSymptomatic":70,
"vaccinePerformRate":0},
"scenario":["days %3D%3D 20",
["gatheringFrequency",$gf],
"days %3D%3D $dr",
["gatheringFrequency",20,$x]],
"out":["asymptomatic","symptomatic","recovered","died",
"dailyTests","dailyTestPositive","dailyTestNegative",
"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >>jobID_$m
echo $x $mb `cat /tmp/s$$`
done
done
rm /tmp/s$$
