#! /bin/bash
# Days
tl=95;ed=22;eyd=2
nyd=$((ed-11))
wd=$((ed-5))
ee=10
dd=$((ed+ee))
dd2=$((ed+29))
dp=$((dd2-dd))
dd3=88
dp1=$((dd3-dd))
dp2=$((95-dd3))
# Size
sz=560
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
# Mobility
mb1=80;mb1m=$((mb1/10))
mb2=$((mb1-10));mb2m=$((mb2/10))
mb3=$((mb2-10));mb3m=$((mb3/10))
# Gatherings
gf0=5;gf1=26;gf2=0.5;gf3=8;gf4=2.5;gf5=3.5;gf6=5
gsz1="[10,40,20]"
gsz2="[4,16,8]"
gpt1="[0,100,20]"
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"popDistMap":"popMap512_1.jpg",
"params":{"populationSize":$s,
  "activenessMode":20,
  "avoidance":70,
  "fatalityBias":20,
  "friction":40,
  "gatheringBias":80,
  "gatheringDuration":[3,12,6],
  "gatheringFrequency":$gf0,
  "gatheringParticipation":$gpt1,
  "gatheringSize":$gsz1,
  "homeMode":2,
  "incubationBias":20,
  "incubation":[2,20,7],
  "infectionProberbility":60,
  "initialInfectedRate":0.1,
  "mobilityBias":80,
  "quarantineAsymptomatic":3,
  "quarantineSymptomatic":70,
  "subjectAsymptomatic":0,
  "subjectSymptomatic":50,
  "vaccineEffectPeriod":100,
  "vaccinePerformRate":0,
  "workPlaceMode":3},
"scenario":[
  "days %3E%3D $eyd",
  ["gatheringFrequency",$gf1,3],
  "days %3E%3D $nyd",
  ["gatheringFrequency",$gf2],
  ["gatheringSize",$gsz2],
  ["mobilityFrequency",[0,$mb1,$mb1m]],
  ["backHomeRate",50],
  "days %3E%3D $wd",
  ["gatheringFrequency",$gf3],
  ["mobilityFrequency",[0,$mb2,$mb2m]],
  ["backHomeRate",75],
  "days %3E%3D $ed",
  ["gatheringFrequency",$gf4,$ee],
  ["mobilityFrequency",[0,$mb3,$mb3m]],
  "days %3E%3D $dd",
  ["gatheringFrequency",$gf5,$dp],
  ["gatheringSize",$gsz1,$dp1],
  ["mobilityFrequency",[0,$mb1,$mb1m],$dp1],
  "days %3E%3D $dd3",
  ["gatheringFrequency",$gf6,$dp2]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
rm /tmp/s$$
