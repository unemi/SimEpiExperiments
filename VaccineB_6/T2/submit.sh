#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1}'`
tl=65 # 65 = Feb. 21
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=5; ;;
esac
for x in {0..9}; do
gf1=`echo $x | awk '{printf "%.1f\n",($1+6)/5}'`
gf2=`echo $x | awk '{printf "%.1f\n",($1+6)/10}'`
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"params":{"populationSize":$s,
  "activenessMode" : 20,
  "avoidance" : 70,
  "fatalityBias" : 20,
  "friction" : 40,
  "gatheringBias" : 80,
  "gatheringDuration" : [3, 12, 6],
  "gatheringFrequency" : 10,
  "gatheringSize" : [10, 40, 20],
  "incubationBias" : 20,
  "initialInfectedRate" : 0.02,
  "mobilityBias" : 80,
  "quarantineAsymptomatic" : 3,
  "quarantineSymptomatic" : 70,
  "subjectAsymptomatic" : 0,
  "subjectSymptomatic" : 20,
  "vaccineEffectPeriod" : 100,
  "vaccinePerformRate" : 0},
"scenario":["days %3D%3D 20",
["gatheringFrequency",$gf1],
"days %3D%3D 27",
["gatheringFrequency",$gf2]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
done
rm /tmp/s$$
