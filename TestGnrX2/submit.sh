#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d0,\"mesh\":%d,\"initialInfected\":%d\n",\
  $1*$1, $1*36, $1*18, $1*$1*4}'`
rm -f jobID
for x in {1..9}; do \
curl http://simepi.intlab.soka.ac.jp/submitJob -s -d @- >>jobID <<EOF
job={"stopAt":200,"n":10,
"params":{"populationSize":$s,
	"subjectAsymptomatic":0.$x,
	"immunity":[400,600,500]},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID
done