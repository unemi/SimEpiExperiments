#! /bin/bash
tl=95
ed=22
eyd=2
nyd=$((ed-11))
# nyd=`echo $ed | awk '{printf "%.1f\n",$1-11}'`
wd=$((ed-3))
dd=$((ed+1))
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
# for x in {0..2}; do
# gf0=6;gf1=28;gf2=0.3;gf3=20;gf4=0.8;gf5=1.4;gf6=1.6;sz=870
# gf0=6;gf1=28;gf2=0.3;gf3=20;gf4=0.8;gf5=1.4;sz=870
gf0=6;gf1=28;gf2=0.3;gf3=20;gf4=0.9;gf5=1.3;sz=870
dd2=85
dp=$((dd2-dd))
# dp2=$((tl-dd2))
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
mb1=80;mb1m=$((mb1/10))
mb2=$((mb1-10));mb2m=$((mb2/10))
mb3=$((mb2-10));mb3m=$((mb3/10))
gsz1="[10,40,20]"
gsz2="[2,8,4]"
gpt1="[0,100,20]"
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"params":{"populationSize":$s,
  "activenessMode" : 20,
  "avoidance" : 70,
  "fatalityBias" : 20,
  "friction" : 40,
  "gatheringBias" : 80,
  "gatheringDuration" : [ 3, 12, 6],
  "gatheringFrequency" : $gf0,
  "gatheringParticipation" : $gpt1,
  "gatheringSize" : $gsz1,
  "homeMode" : 2,
  "incubationBias" : 20,
  "incubation" : [ 2, 20, 7 ],
  "infectionProberbility" : 80,
  "initialInfectedRate" : 0.1,
  "mobilityBias" : 80,
  "quarantineAsymptomatic" : 3,
  "quarantineSymptomatic" : 70,
  "subjectAsymptomatic" : 0,
  "subjectSymptomatic" : 50,
  "vaccineEffectPeriod" : 100,
  "vaccinePerformRate" : 0},
"scenario":[
  "days %3E%3D $eyd",
  ["gatheringFrequency",$gf1,3],
  "days %3E%3D $nyd",
  ["gatheringFrequency",$gf2],
  ["gatheringSize",$gsz2],
  ["mobilityFrequency",[0,$mb1,$mb1m]],
  ["backHomeRate",20],
  "days %3E%3D $wd",
  ["gatheringFrequency",$gf3],
  ["mobilityFrequency",[0,$mb2,$mb2m]],
  ["backHomeRate",75],
  "days %3E%3D $ed",
  ["gatheringFrequency",$gf4],
  ["mobilityFrequency",[0,$mb3,$mb3m]],
  "days %3E%3D $dd",
  ["gatheringFrequency",$gf5,$dp],
  ["gatheringSize",$gsz1,$dp],
  ["mobilityFrequency",[0,$mb1,$mb1m],$dp]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
# ,
#   "days %3E%3D $dd2",
#   ["gatheringFrequency",$gf6,$dp2]
#
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
# done
rm /tmp/s$$
