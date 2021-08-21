#! /bin/bash
pp=`pwd | awk -F/ '{print substr($NF,2,1)}'`
ed=22
# tl=`awk 'END{print $1-316-'$ed'+3}' \
#  /Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv`
tl=166
eyd=1
nyd=10
wd=16
ee=1
dd=$((ed+18))
dd2=90
rd=95
dd3=$((rd+10))
dp1=$((dd2-dd));dp2=4
#
mb1=80;mb1m=$((mb1/10))
mb2=$((mb1-10));mb2m=$((mb2/10))
mb3=$((mb2-10));mb3m=$((mb3/10))
#
gf0=2;gf1=9.5;gf2=0.01;gf3=2;gf4=0.65;gf7=1.8
gsz1="[10,40,20]";gsz2="[4,16,8]";gpt1="[0,100,20]"
infcProb=50;infcProb2=75
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
# for m in simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
sz=620
s=`echo $pp | awk '{n=$1;printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
# for gf4 in 0.4 0.5 0.6; do gf5=$gf4; x=$gf4
# cat <<EOF
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "activenessMode":20,
  "avoidance":70,
  "fatalityBias":20,
  "friction":40,
  "gatheringBias":80,
  "gatheringDuration":[3,12,6],
  "gatheringFrequency":$gf0,
  "gatheringParticipation":[0,100,20],
  "gatheringSize":$gsz1,
  "immunity":[400,400,400],
  "incubation":[2,20,7],
  "incubationBias":20,
  "infectionProberbility":$infcProb,
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
  ["gatheringSize",$gsz1,$dp1],
  ["mobilityFrequency",[0,$mb1,$mb1m],$dp1],
  "days %3E%3D $rd",
  ["gatheringFrequency",$gf7,$dp2],
  "days %3E%3D $dd3",
  ["infectionProberbility",$infcProb2,4]],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
# done
done
rm /tmp/s$$
