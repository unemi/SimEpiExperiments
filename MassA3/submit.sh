#! /bin/bash
# Population density = 40k/km^2
#
p=`pwd | awk '{n=substr($0,length($0),1);\
printf "%d0000,\"initialInfected\":%d,\"mesh\":%d,\"worldSize\":%d\n",\
n*n,n*n*4,n*20,n*500}'`
nn=3
for m in simepi simepi2; do \
rm -f jobID_$m
for x in {1..8}; do \
ma=`echo $x | awk '{printf "[%d,%d,%d]\n",$1*5,$1*15,$1*10}'`
curl http://$m.intlab.soka.ac.jp/submitJob -s -d @- >>jobID_$m <<EOF
job={"stopAt":200,"n":$nn,
"params":{"populationSize":$p,
"mass":$ma,
"avoidance":50,
"contactTracing":20,
"contagionDelay":0.5,
"contagionPeak":3,
"distancingObedience":20,
"distancingStrength":50,
"fatality":[4,20,16],
"friction":50,
"gatheringDuration":[24,168,48],
"gatheringFrequency":30,
"gatheringSize":[5,20,10],
"gatheringStrength":[50,100,80],
"immunity":[400,600,500],
"incubation":[1,14,5],
"infectionDistance":3,
"infectionProberbility":80,
"maxSpeed":100,
"mobilityDistance":[10,80,30],
"mobilityFrequency":50,
"recovery":[4,40,10],
"stepsPerDay":16,
"subjectAsymptomatic":1,
"subjectSymptomatic":99,
"testDelay":1,
"testInterval":2,
"testProcess":1,
"testSensitivity":70,
"testSpecificity":99.8},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID_$m
done
nn=2
done
