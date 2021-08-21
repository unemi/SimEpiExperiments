#! /bin/bash
p=`pwd | awk '{n=substr($0,length($0),1);printf "%d0000,\"initialInfected\":%d\n",n*n,n*n*4}'`
rm -f jobID
for x in {0..10}; do \
s=`echo $x | awk '{x=sqrt(1+$1*0.1);printf "%d,\"mesh\":%d\n",x*1080,x*54}'`
echo $s >> sizes
echo $s
curl http://simepi2.intlab.soka.ac.jp/submitJob -s -d @- >>jobID <<EOF
job={"stopAt":200,"n":10,
"params":{"populationSize":$p,"worldSize":$s,
	"immunity":[400,600,500]},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative",
	"incubasionPeriod", "recoveryPeriod", "fatalPeriod", "infects"]}
EOF
echo "" >>jobID
done