#! /bin/bash
s=1581
m=simepi2
x=8
curl http://$m.intlab.soka.ac.jp/submitJob -s -d @- >>jobID_x <<EOF
job={"stopAt":200,"n":2,
"params":{"populationSize":100000,"worldSize":$s,"mesh":50,"immunity":[400,600,500],
	"mass":10,"maxSpeed":${x}0},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID_x
s=1414
m=simepi
x=6
curl http://$m.intlab.soka.ac.jp/submitJob -s -d @- >>jobID_x <<EOF
job={"stopAt":200,"n":2,
"params":{"populationSize":100000,"worldSize":$s,"mesh":50,"immunity":[400,600,500],
	"mass":10,"maxSpeed":${x}0},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID_x
