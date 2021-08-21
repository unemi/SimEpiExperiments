#! /bin/bash
# 4 gf1=0.27;gf2=0.42;gf3=1.2;gf4=1.5;rrd2=152;rr2=8;rrd3=162;rr3=18;vsd=174;vdd=30;gfEL=2
# 5 gf1=0.27;gf2=0.42;gf3=1.1;gf4=1.5;rrd2=152;rr2=8;rrd3=162;rr3=18;vsd=174;vdd=30;gfEL=2
# 6 gf1=0.27;gf2=0.4;gf3=1.1;gf4=1.5;rrd2=152;rr2=8;rrd3=162;rr3=17;vsd=174;vdd=30;gfEL=2.2
# 7 gf1=0.27;gf2=0.38;gf3=1.1;gf4=1.5;rrd2=152;rr2=14;rrd3=166;rr3=17;vsd=174;vdd=30;gfEL=2.2
# 8 gf1=0.27;gf2=0.38;gf3=1.1;gf4=1.5;rrd2=152;rr2=10;rrd3=162;rr3=17;vsd=174;vdd=30;gfEL=2.2
gf1=0.27;gf2=0.38;gf3=1.1;gf4=1.5;rrd2=152;rr2=12;rrd3=164;rr3=17;vsd=174;vdd=30;gfEL=2.2
# Days
tl=201 # July 5
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=4; iFrom=1;iN=6; ;;
  simepi2) nn=4; iFrom=7;iN=2; ;;
  *) nn=12; iFrom=`echo $m | awk '{print substr($1,length($1),1)+1}'`;iN=1; ;;
esac
for ((x=0;x<iN;x++)); do
sed '/^#/d' > /tmp/d$$_${m}_$x <<EOF
{"stopAt":$tl,"n":$nn,
"loadState":"B150_640K_$((x+iFrom))",
"scenario":[
  "days %3E%3D 151",["gatheringFrequency",$gf1,1],
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],
  "days %3E%3D $rrd3",["gatheringFrequency",$gf3,$rr3],
# Delta variant
  "days %3E%3D $vsd",["infectionProberbility",84.375,$vdd],["vaccineMaxEfficacy",83,$vdd],
# Mass vaccination center starts for younger generations
  "days %3E%3D 183",["vaccinePerformRate",6,14],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 186",["gatheringFrequency",$gf4,1],
  "days %3E%3D 191",["gatheringFrequency",$gfEL],["mobilityFrequency",[0,80,20]]
  ],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
