#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1}'`
gf=`pwd | awk -F_ '{print 2*$2/10}'`
dr=`pwd | awk -F_ '{print $3}'` # day to release 86=Mar 14
pf=".intlab.soka.ac.jp"
m=simepi
sv=104
nn=4
for x in 4 10; do \
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":200,"n":$nn,
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
["gatheringFrequency",20],
"days %3D%3D $sv",
["vaccinePerformRate",$x]],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"dailyTests","dailyTestPositive","dailyTestNegative",
"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $mb `cat /tmp/s$$`
nn=7
done
rm /tmp/s$$
