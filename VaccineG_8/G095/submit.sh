#! /bin/bash
# Days
tl=95
# Size
sz=720
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "activenessMode":20,
  "avoidance":70,
  "fatalityBias":20,
  "friction":40,
  "gatheringBias":80,
  "gatheringDuration":[3,12,6],
  "gatheringFrequency":2,
  "gatheringParticipation":[0,100,20],
  "gatheringSize":[10,40,20],
  "incubation":[2,20,7],
  "incubationBias":20,
  "infectionProberbility":75,
  "mobilityBias":80,
  "quarantineAsymptomatic":3,
  "quarantineSymptomatic":70,
  "subjectAsymptomatic":0,
  "subjectSymptomatic":50,
  "vaccineEffectPeriod":100,
  "vaccinePerformRate":0,
  "workPlaceMode":3},
"scenario":[
  "days %3E%3D 2",
  ["gatheringFrequency",9,3],
  "days %3E%3D 10.5",
  ["gatheringFrequency",0.01],
  ["gatheringSize",[4,16,8]],
  ["mobilityFrequency",[0,80,8]],
  ["backHomeRate",50],
  "days %3E%3D 17",
  ["gatheringFrequency",2],
  ["mobilityFrequency",[0,70,7]],
  ["backHomeRate",75],
  "days %3E%3D 22",
  ["gatheringFrequency",0.9,10],
  ["mobilityFrequency",[0,60,6]],
  "days %3E%3D 44",
  ["gatheringSize",[10,40,20],46],
  ["mobilityFrequency",[0,80,8],46],
  "days %3E%3D 90",
  ["gatheringFrequency",1.5,5]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
rm /tmp/s$$
