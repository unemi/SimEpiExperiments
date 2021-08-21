#! /bin/bash
gf1=0.27
gf2=0.38;rrd2=152;rr2=12
# gf3=1.1;rrd3=164;rr3=17
#
# 1 gf4=1.3;rrd4=2;gfEL=1.6;eld=191;els=7;gfM2=1.4
# 2 gf4=1.5;rrd4=2;gfEL=1.8;eld=191;els=7;gfM2=1.6
# 3 gf4=1.6;rrd4=2;gfEL=2.2;eld=191;els=7;gfM2=2
# 4 gf3=1.2;rrd3=164;rr3=19;gf4=1.5;rrd4=2;gfEL=2;eld=191;els=7;gfM2=1.8
# 5 gf3=1.2;rrd3=164;rr3=17;gf4=1.5;rrd4=2;gfEL=1.9;eld=191;els=6;gfM2=1.7
# 6 gf3=1.2;rrd3=164;rr3=17;gf4=1.5;rrd4=2;gfEL=2;eld=191;els=9;gfM2=1.9
gf3=1.1;rrd3=164;rr3=10;gf4=1.5;rrd4=174;rr4=7;gf5=1.6;gfEL=2.4;eld=191;els=10;gfM2=2
vsd=174;vdd=50
# Days
tl=215 # July 19
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
  "days %3E%3D $rrd4",["gatheringFrequency",$gf4,$rr4],
# Delta variant
  "days %3E%3D $vsd",["infectionProberbility",84.375,$vdd],["vaccineMaxEfficacy",64,$vdd],
# Mass vaccination center starts for younger generations
  "days %3E%3D 183",["vaccinePerformRate",6,14],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 186",["gatheringFrequency",$gf5,1],
  "days %3E%3D $eld",["gatheringFrequency",$gfEL,$els],["mobilityFrequency",[0,80,20],$els],
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]]
  ],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
