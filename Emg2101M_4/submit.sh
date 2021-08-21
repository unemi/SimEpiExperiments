#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1}'`
pf=".intlab.soka.ac.jp"
nn=6
for m in simepi simepi2; do \
rm -f jobID_$m
for x in {0..10}; do \
mm=`echo $x | awk '{printf "%d,%d,%d\n",$1*4,$1*10,$1*7}'`
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":200,"n":$nn,
"params":{"populationSize":$s,
"fatalityBias":20,
"gatheringFrequency":20,
"incubationBias":20,
"initialInfectedRate":0.12,
"quarantineAsymptomatic":3,
"quarantineSymptomatic":70},
"scenario":["days %3D%3D 20",
["mobilityFrequency",[$mm]],
["gatheringFrequency",20]],
"out":["asymptomatic","symptomatic","recovered","died",
"dailyTests","dailyTestPositive","dailyTestNegative",
"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >>jobID_$m
echo $x $mb `cat /tmp/s$$`
done
nn=4
done
rm /tmp/s$$
