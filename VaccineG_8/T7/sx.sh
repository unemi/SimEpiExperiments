#! /bin/bash
tl=102
ed=22;eyd=2
nyd=10.5
wd=17
ee=4
dd=$((ed+ee))
dd2=51;dp=$((dd2-dd))
dd3=65;dp1=$((dd3-dd))
dd4=88;dp2=$((dd4-dd3));dp3=$((95-dd4))
#
mb1=80;mb1m=$((mb1/10))
mb2=$((mb1-10));mb2m=$((mb2/10))
mb3=$((mb2-10));mb3m=$((mb3/10))
#
gf0=1;gf1=9;gf2=0.01;gf3=1;gf4=0.8;gf5=0.8;gf6=0.7;gf7=1.4
gsz1="[10,40,20]";gsz2="[4,16,8]";gpt1="[0,100,20]"
#
pf=".intlab.soka.ac.jp"
# for m in simepiM0{0..7} simepi2 simepi; do
for m in simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
sz=720
s=`echo 8 | awk '{n=$1;printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
# for gf4 in 0.4 0.5 0.6; do gf5=$gf4; x=$gf4
cat <<EOF
# curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":102,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "activenessMode":20,
  "avoidance":70,
  "fatalityBias":20,
  "friction":40,
  "gatheringBias":80,
  "gatheringDuration":[3,12,6],
  "gatheringFrequency":2,
  "gatheringParticipation":[0,100,20],
  "gatheringSize":[10,40,20],
  "incubation":[2,20,7],
  "incubationBias":20,
  "infectionProberbility":75,
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
  ["gatheringFrequency",$gf6,$dp2],
  "days %3E%3D $dd4",
  ["gatheringFrequency",$gf7,$dp3]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
# if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
# echo `cat /tmp/s$$` >> jobID_$m
# echo $x $m `cat /tmp/s$$`
# done
done
# rm /tmp/s$$
