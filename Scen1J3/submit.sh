#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d0,\"mesh\":%d,\"initialInfected\":%d\n",\
  $1*$1, $1*36, $1*18, $1*$1*4}'`
rm -f jobID
for ((x=40;x<=70;x+=5)); do \
echo $x
curl http://simepi2.intlab.soka.ac.jp/submitJob -s -d @- >>jobID <<EOF
job={"stopAt":365,"n":10,
"params":{"populationSize":$s,
	"contactTracing":10,"mobilityFrequency":70,"mobilityDistance":[10,80,30],
	"subjectAsymptomatic":0,"subjectSymptomatic":99,
	"immunity":[5,30,15],
	"gatheringFrequency":70,"gatheringDuration":[1.5,24,3],"gatheringSize":[5,20,10],
	"distancingObedience":0,
	"infectionProberbility":70},
"scenario":["days %3D%3D 18",["infectionProberbility",$x],
	"days %3D%3D 50",["distancingObedience",30],
	"days %3D%3D 80",["distancingObedience",50],["mobilityFrequency",15],["gatheringFrequency",15],
	"days %3D%3D 130",["mobilityFrequency",40],
	"days %3D%3D 150",["gatheringFrequency",50],
	"days %3D%3D 180",["gatheringFrequency",60],
	"days %3D%3D 190",["mobilityFrequency",50],
	"days %3D%3D 250",["gatheringFrequency",70],
	"days %3D%3D 260",["mobilityFrequency",70]],
"out":["asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID
done
