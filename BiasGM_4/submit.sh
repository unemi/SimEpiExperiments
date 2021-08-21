#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d,\"initialInfected\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1}'`
pf=".intlab.soka.ac.jp"
for m in simepi simepi2; do \
rm -f jobID_$m
# for x in {0..10}; do \
for ((x=0;x<=100;x+=20)); do \
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":400,"n":5,
  "params":{"populationSize":$s,
  "massBias" : 4,
  "mobilityBias" : $x,
  "gatheringBias" : $x,
  "gatheringDuration" : [3,12,6],
  "gatheringFrequency" : 25,
  "gatheringSize" : [10,30,20],
  "immunity" : [400,600,500]
  },
"out":["asymptomatic","symptomatic","recovered","died",
	"dailyTests","dailyTestPositive","dailyTestNegative",
	"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >>jobID_$m
echo $x $mb `cat /tmp/s$$`
done
done
rm /tmp/s$$
