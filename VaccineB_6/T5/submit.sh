#! /bin/bash
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*500, n*25}'`
ed=22
nyd=`expr $ed - 6`
wd=`expr $ed - 4`
ld=`expr $ed + 66`
vd=`expr $ed + 94`
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nn=4; ;;
  simepi2) nn=2; ;;
  *) nn=3; ;;
esac
for x in {6..9}; do
gf=`echo $x | awk '{printf "%.1f\n",$1*0.1}'`
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":160,"n":$nn,
"params":{"populationSize":$s,
  "activenessMode" : 20,
  "avoidance" : 70,
  "fatalityBias" : 20,
  "friction" : 40,
  "gatheringBias" : 80,
  "gatheringDuration" : [ 3, 12, 6 ],
  "gatheringFrequency" : 4,
  "gatheringSize" : [ 10, 40, 20 ],
  "immunity" : [ 400, 600, 500 ],
  "incubationBias" : 20,
  "infectionProberbility" : 80,
  "initialInfectedRate" : 0.02,
  "mobilityBias" : 80,
  "quarantineAsymptomatic" : 3,
  "quarantineSymptomatic" : 70,
  "subjectAsymptomatic" : 0,
  "subjectSymptomatic" : 50,
  "vaccineEffectPeriod" : 100,
  "vaccinePerformRate" : 0},
"scenario":["days %3D%3D $nyd",
  ["gatheringFrequency", 0.5],
  "days %3D%3D $wd",
  ["gatheringFrequency",1],
  "days %3D%3D $ed",
  ["gatheringFrequency",0.$x,4],
  "days %3D%3D $ld",
  ["gatheringFrequency",4],
  "days %3D%3D $vd",
  ["vaccinePerformRate",2]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
done
rm /tmp/s$$
