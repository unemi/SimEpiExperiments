#! /bin/bash
for m in simepi simepi2; do \
for ((x=30;x<50;x+=2)); do \
echo $x
curl http://$m.intlab.soka.ac.jp/submitJob -s -d @- >>jobID_$m <<EOF
job={"stopAt":365,"n":5,
"params":{"avoidance":50,"contactTracing":10,"contagionDelay":0.5,"contagionPeak":3,"distancingObedience":0,"distancingStrength":50,"fatality":[4,20,16],"friction":50,"gatheringDuration":[1.5,24,3],"gatheringFrequency":70,"gatheringSize":[5,20,10],"gatheringStrength":[50,100,80],"immunity":[5,30,15],"incubation":[1,30,5],"infectionDistance":3,"infectionProberbility":80,"initialInfected":16,"mass":[2,80,10],"maxSpeed":50,"mesh":50,"mobilityDistance":[10,80,30],"mobilityFrequency":70,"populationSize":100000,"recovery":[4,40,10],"stepsPerDay":16,"subjectAsymptomatic":0,"subjectSymptomatic":20,"testDelay":1,"testInterval":2,"testProcess":1,"testSensitivity":70,"testSpecificity":99.8,"worldSize":1580},
"scenario":["days %3D%3D 18",["infectionProberbility",70],
"days %3D%3D 50",["distancingObedience",20],["infectionProberbility",60],
"days %3D%3D 80",["distancingObedience",25],["mobilityFrequency",$x],["gatheringFrequency",30],
"days %3D%3D 116",["subjectSymptomatic",50],
"days %3D%3D 130",["mobilityFrequency",50],["gatheringFrequency",40],
"days %3D%3D 150",["gatheringFrequency",50],
"days %3D%3D 180",["gatheringFrequency",60],
"days %3D%3D 190",["mobilityFrequency",60],
"days %3D%3D 250",["gatheringFrequency",70],
"days %3D%3D 260",["mobilityFrequency",70]],
"out":["asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID_$m
done
done