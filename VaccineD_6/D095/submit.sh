#! /bin/bash
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*711, n*25}'`
tl=`pwd | awk -F/ '{printf "%d\n",substr($NF,2,3)}'`
ed=22
nyd=`echo $ed | awk '{print $1 - 10.4}'`
wd=`expr $ed - 4`
dd=`expr $ed + 1`
dp=`expr $ed + 30 - $dd`
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
gf1=28
gf2=1.25
gf3=3
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
  ["gatheringFrequency",0.2],
  "days %3E%3D $wd",
  ["gatheringFrequency",5],
  "days %3E%3D $ed",
  ["gatheringFrequency",$gf2],
  "days %3E%3D $dd",
  ["gatheringFrequency",$gf3,$dp]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
rm /tmp/s$$
