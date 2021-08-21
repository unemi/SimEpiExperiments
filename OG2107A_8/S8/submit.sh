#! /bin/bash
gf1=0.5;gf2=0.4;gf4=0.7
# Days
tl=173 # June 7
# Size
sz=590
s=`pwd | awk -F/ '{d=$NF;n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=22; ;;
  simepi2) nn=10; ;;
  *) nn=12; ;;
esac
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "activenessMode":20,"antiVaxTestRate":100,"avoidance":70,
  "fatalityBias":20,"friction":40,
  "gatheringBias":80,"gatheringDuration":[3,12,6],"gatheringFrequency":1.2,
  "gatheringParticipation":[0,100,20],"gatheringSize":[10,40,20],
  "immunity":[400,400,400],"incubation":[2,20,7],"incubationBias":20,
  "infectionProberbility":50,"initialInfectedRate":0.2,"mobilityBias":80,
  "quarantineAsymptomatic":3,"quarantineSymptomatic":70,
  "subjectAsymptomatic":0,"subjectSymptomatic":50,
  "vaccineEffectPeriod":100,"vaccinePerformRate":0,"vaccinePriority":2,"workPlaceMode":3},
"scenario":[
  "days %3E%3D 1",["gatheringFrequency",0.9,1],
  "days %3E%3D 2",["gatheringFrequency",19,2],
  "days %3E%3D 5",["gatheringFrequency",0.3],["gatheringSize",[4,16,8]],
  ["mobilityFrequency",[0,80,8]],["backHomeRate",50],
  "days %3E%3D 16",["gatheringFrequency",1.2],["mobilityFrequency",[0,70,7]],
  ["backHomeRate",75],
  "days %3E%3D 20",["gatheringFrequency",0.4,2],["mobilityFrequency",[0,60,6],2],
  "days %3E%3D 42",["gatheringFrequency",0.7,35],["gatheringSize",[10,40,20],35],
  ["mobilityFrequency",[0,80,8],35],
  "days %3E%3D 83",["vaccinePerformRate",0.82,48],
  "days %3E%3D 95",["gatheringFrequency",1.2,2],
  "days %3E%3D 110",["infectionProberbility",75,10],
  "days %3E%3D 117",["gatheringFrequency",$gf1,1],["gatheringSize",[10,40,20],1],
  "days %3E%3D 131",["gatheringFrequency",$gf2,10],
  "days %3E%3D 145",["vaccinePerformRate",3.3,21],
  "days %3E%3D 151",["gatheringFrequency",$gf4,35]
  ],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
rm /tmp/s$$
LANG=C date
