#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1}'`
ip=`pwd | awk -F_ '{print $2}'`
pf=".intlab.soka.ac.jp"
for m in simepi simepi{2,M00,M01}; do \
rm -f jobID_$m
for ((x=0;x<=20;x+=2)); do \
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":200,"n":5,
"params":{"populationSize":$s,
"fatalityBias":20,
"gatheringFrequency":20,
"incubationBias":20,
"infectionProberbility":$ip,
"initialInfectedRate":0.12,
"quarantineAsymptomatic":3,
"quarantineSymptomatic":70},
"scenario":["days %3D%3D 20",
["mobilityFrequency",[40, 100, 70]],
["gatheringFrequency",$x]],
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
