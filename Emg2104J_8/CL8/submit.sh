#! /bin/bash
pp=`pwd | awk -F/ '{print substr($NF,length($NF),1)}'`
tl=258 # August 31
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
# for m in simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
sz=620
s=`echo $pp | awk '{n=$1;printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
# for avcr in 20 40 60 80 100; do
for avcr in 0 ; do
# cat <<EOF
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "antiVaxClusterRate":$avcr,
  "activenessMode":20,
  "avoidance":70,
  "fatalityBias":20,
  "friction":40,
  "gatheringBias":80,
  "gatheringDuration":[3,12,6],
  "gatheringFrequency":2,
  "gatheringParticipation":[0,100,20],
  "gatheringSize":[10,40,20],
  "immunity":[400,400,400],
  "incubation":[2,20,7],
  "incubationBias":20,
  "infectionProberbility":50,
  "mobilityBias":80,
  "quarantineAsymptomatic":3,
  "quarantineSymptomatic":70,
  "subjectAsymptomatic":0,
  "subjectSymptomatic":50,
  "vaccineEffectPeriod":100,
  "vaccinePerformRate":0,
  "workPlaceMode":3},
"scenario":[
  "days %3E%3D 1",
  ["gatheringFrequency",11,3],
  "days %3E%3D 9",
  ["gatheringFrequency",0.01],
  ["gatheringSize",[4,16,8]],
  ["mobilityFrequency",[0,80,8]],
  ["backHomeRate",50],
  "days %3E%3D 16",
  ["gatheringFrequency",2],
  ["mobilityFrequency",[0,70,7]],
  ["backHomeRate",75],
  "days %3E%3D 22",
  ["gatheringFrequency",0.19,0.5],
  ["mobilityFrequency",[0,60,6]],
  "days %3E%3D 37",
  ["gatheringFrequency",0.62,46],
  ["gatheringSize",[10,40,20],46],
  ["mobilityFrequency",[0,80,8],46],
  "days %3E%3D 95",
  ["gatheringFrequency",1.1,7],
  "days %3E%3D 112",
  ["infectionProberbility",68,14],
  "days %3E%3D 131",
  ["vaccinePerformRate",3]],
"out":["asymptomatic","symptomatic","died",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $m $avcr `cat /tmp/s$$`
done
done
rm /tmp/s$$
