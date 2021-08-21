#! /bin/bash
s=1581
for m in simepi simepi2; do \
rm -f jobID_${s}_$m
for x in {1..10}; do \
curl http://$m.intlab.soka.ac.jp/submitJob -s -d @- >>jobID_${s}_$m <<EOF
job={"stopAt":200,"n":10,
"params":{"populationSize":100000,"worldSize":$s,"mesh":50,"immunity":[400,600,500],
	"mass":10,"maxSpeed":${x}0},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID_${s}_$m
done
s=1414
done
