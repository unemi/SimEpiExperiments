#! /bin/bash
p=`pwd | awk -F/ '{split($NF,a,"_");n=a[2];printf "%d0000,\"initialInfected\":%d\n",n,n*4}'`
rm -f jobID
for x in {1..10}; do \
s=`echo $x | awk '{x=sqrt(10/$1);printf "%d\n",x*1000}'`
echo $s >> sizes
echo $s
curl http://simepi2.intlab.soka.ac.jp/submitJob -s -d @- >>jobID <<EOF
job={"stopAt":200,"n":10,
"params":{"populationSize":$p,"worldSize":$s,"mesh":50,
	"immunity":[400,600,500]},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID
done