#! /bin/bash
s=1581
for m in simepi simepi2; do \
rm -f jobID_$m
for ((x=15;x<50;x+=5)); do \
curl http://$m.intlab.soka.ac.jp/submitJob -s -d @- >>jobID_$m <<EOF
job={"stopAt":200,"n":5,
"params":{"populationSize":100000,"worldSize":$s,"mesh":50,"immunity":[400,600,500],
	"maxSpeed":50,"mass":$x},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID_$m
done
done
