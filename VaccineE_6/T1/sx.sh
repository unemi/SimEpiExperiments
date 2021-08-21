#! /bin/bash
tl=95
ed=22
nyd=`echo $ed | awk '{print $1 - 10.8}'` # 8-
wd=`expr $ed - 3` # 10-
dd=`expr $ed + 1`
dp=`expr 95 - $dd` # 11,12
pf=":8000"
m="localhost"
rm -f jobID_$m
nn=1
gf1=32;gf2=0;gf3=0.1;gf4=0.04;gf5=1;sz=765 #... 13
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"params":{"populationSize":$s,
  "activenessMode" : 20,
  "avoidance" : 70,
  "fatalityBias" : 20,
  "friction" : 40,
  "gatheringBias" : 80,
  "gatheringDuration" : [ 3, 12, 6],
  "gatheringFrequency" : $gf1,
  "gatheringParticipation" : [ 0, 100, 20],
  "gatheringSize" : [ 10, 40, 20],
  "homeMode" : 2,
  "incubationBias" : 20,
  "incubation" : [ 2, 20, 7 ],
  "infectionProberbility" : 80,
  "initialInfectedRate" : 0.02,
  "mobilityBias" : 80,
  "quarantineAsymptomatic" : 3,
  "quarantineSymptomatic" : 70,
  "subjectAsymptomatic" : 0,
  "subjectSymptomatic" : 50,
  "vaccineEffectPeriod" : 100,
  "vaccinePerformRate" : 0},
"scenario":["days %3E%3D $nyd",
  ["gatheringFrequency",$gf2],
  ["mobilityFrequency",[0,100,90]],
  ["backHomeRate":20],
  "days %3E%3D $wd",
  ["gatheringFrequency",$gf3],
  ["mobilityFrequency",[10,50,40]],
  ["backHomeRate":75],
  "days %3E%3D $ed",
  ["gatheringFrequency",$gf4],
  ["mobilityFrequency",[10,50,30]],
  "days %3E%3D $dd",
  ["gatheringFrequency",$gf5,$dp],
  ["mobilityFrequency",[20,80,70],$dp]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
rm /tmp/s$$
