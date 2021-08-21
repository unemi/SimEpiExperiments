#! /bin/bash
#gf1=0.5;gf2=0.4;gf4=0.7
gf1=0.5;gf2=0.37;gf4=0.7;gf5=0.85
rrd1=47;rr1=28 # relaxing speed
rr2=21
vdd=30 # Delta variant speading speed
# Days
#tl=192 # June 26
tl=150
# Size
sz=620
s=`pwd | awk -F/ '{d=$NF;n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
sed '/^#/d' <<EOF | curl http://$m$pf/submitJob -s -d @- > /tmp/s$$
job={"stopAt":$tl,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "activenessMode":20,"antiVaxTestRate":100,"avoidance":70,
  "fatalityBias":20,"friction":40,
  "gatheringBias":80,"gatheringDuration":[3,12,6],"gatheringFrequency":1.2,
  "gatheringParticipation":[0,100,20],"gatheringSize":[10,40,20],
  "incubation":[2,20,7],"incubationBias":20,
  "infectionProberbility":50,"mobilityBias":80,
  "quarantineAsymptomatic":3,"quarantineSymptomatic":70,
  "subjectAsymptomatic":0,"subjectSymptomatic":50,
  "vaccineEffectPeriod":400,"vaccinePerformRate":0,"workPlaceMode":3},
"scenario":[
  "days %3E%3D 1",["gatheringFrequency",9.5,3],
  "days %3E%3D 10",["gatheringFrequency",0.01],["gatheringSize",[4,16,8]],
  ["mobilityFrequency",[0,80,8]],["backHomeRate",50],
  "days %3E%3D 16",["gatheringFrequency",2],["mobilityFrequency",[0,70,7]],
  ["backHomeRate",75],
# Emergency Declaration in January 7.
  "days %3E%3D 22",["gatheringFrequency",0.52,1],["mobilityFrequency",[0,60,6]],
# Relaxing
  "days %3E%3D $rrd1",["gatheringFrequency",0.68,$rr1],["gatheringSize",[10,40,20],$rr1],
  ["mobilityFrequency",[0,80,8],$rr1],
# Vaccination starts from Medical workers.
  "days %3E%3D 83",["vaccinePerformRate",0.82,48],
# Lifting emergency delaration in March 21.
  "days %3E%3D 95",["gatheringFrequency",1.1,2],
# Alpha variant
  "days %3E%3D 110",["infectionProberbility",75,20],
# Restricter Measures in April 12.
  "days %3E%3D 117",["gatheringFrequency",$gf1,1],["gatheringSize",[10,40,20],1],
# Emergency Declaration (Tokyo, Osaka, ...) in April 25
  "days %3E%3D 130",["gatheringFrequency",$gf2,4.5],
# General vaccination from innactive citizens
  "days %3E%3D 145",["vaccinePriority",2],["vaccinePerformRate",4,21],
  "days %3E%3D 151",["gatheringFrequency",$gf4,$rr2],
# Delta variant
  "days %3E%3D 185",["infectionProberbility",86,$vdd],["vaccineMaxEfficacy",83,$vdd],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 186",["gatheringFrequency",$gf5,1],
  ],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative","saveState"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
rm /tmp/s$$
LANG=C date
