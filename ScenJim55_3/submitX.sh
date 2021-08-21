#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d,\"initialInfected\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1*4}'`
echo $s
pf=".intlab.soka.ac.jp"
declare -a p=`echo 5.5 | awk '{printf "(%.1f %.1f %.1f %.1f)",$1*10,$1*5,$1*4,$1*7}'`
for m in simepi; do \
# rm -f jobID_$m
for x in 4; do \
im=`echo $x | awk '{printf "[%d,%d,%d]",$1*10,$1*50,$1*20}'`
# original imunity = [15,180,60]
curl http://$m$pf/submitJob -s -d @- >>jobID_${m}_X <<EOF
job={"n":1,
  "params":{"populationSize":$s,
    "avoidance":90,
    "contactTracing":15,
    "contagionDelay":0.5,
    "contagionPeak":3,
    "distancingObedience":0,
    "distancingStrength":50,
    "fatality":[4,20,16],
    "friction":40,
    "gatheringDuration":[2,24,4],
    "gatheringFrequency":80,
    "gatheringSize":[10,30,20],
    "gatheringStrength":[100,200,150],
    "immunity":$im,
    "incubation":[1,30,5],
    "infectionDistance":3,
    "infectionProberbility":70,
    "mass":10,
    "maxSpeed":60,
    "mobilityDistance":[10,80,30],
    "mobilityFrequency":80,
    "recovery":[4,40,10],
    "stepsPerDay":16,
    "subjectAsymptomatic":0,
    "subjectSymptomatic":10,
    "testDelay":4,
    "testInterval":4,
    "testProcess":1,
    "testSensitivity":70,
    "testSpecificity":99.799999999999997},
  "scenario":[
    ["infectionProberbility",${p[0]}],
    ["gatheringDuration",[6,24,12]],
    ["WHO 緊急事態宣言","days %3D%3D 14"],
    ["infectionProberbility",${p[1]},10],
    ["gatheringFrequency",50,5],
    ["専門家会議から呼びかけ","days %3D%3D 53"],
    ["infectionProberbility",${p[2]},25],
    ["distancingObedience",10,25],
    ["緊急事態宣言発令","days %3D%3D 82"],
    ["distancingObedience",30,3],
    ["mobilityFrequency",20,3],
    ["gatheringFrequency",20,3],
    ["gatheringSize",[7,15,10],3],
    ["受診の目安緩和","days %3D%3D 116"],
    ["testDelay",1,14],
    ["緊急事態宣言解除","days %3D%3D 130"],
    ["infectionProberbility",${p[3]},30],
    ["mobilityFrequency",55,2],
    ["gatheringFrequency",50,2],
    ["gatheringSize",[5,20,10],2],
    ["集会制限緩和","days %3D%3D 148"],
    ["gatheringFrequency",60,5],
    ["gatheringSize",[5,30,15],5],
    ["集会制限緩和","days %3D%3D 176"],
    ["gatheringFrequency",70,5],
    ["gatheringSize",[10,30,20],5],
    ["GOTO 第１弾","days %3D%3D 188"],
    ["mobilityFrequency",60,5],
    ["集会制限緩和","days %3D%3D 247"],
    ["gatheringFrequency",80,5],
    ["GOTO 第２弾","days %3D%3D 259"],
    ["mobilityFrequency",80,3],
    ["季節性流行","days %3D%3D 300"],
    ["infectionProberbility",${p[0]},20]
  ],
  "stopAt":365,
"out":["asymptomatic","symptomatic","recovered","died",
	"dailyTests","dailyTestPositive","dailyTestNegative",
	"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
echo "" >>jobID_${m}_X
echo $x
done
done
