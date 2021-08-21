#! /bin/bash
base=B150
gf1=0.27
gf2=0.38;rrd2=152;rr2=12
gf3=1.1;rrd3=164;rr3=17
gf4=1.3;rrd4=2;gfEL=1.6;eld=191;els=7;gfM2=1.4
vsd=174;vdd=30
tl=190
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=2; nFrom=1; nTo=6; ;;
  simepi2) nn=2; nFrom=7; nTo=8; ;;
  *) nn=6; nFrom=`echo $m | awk '{print substr($1,length($1),1)+1}'`; nTo=$nFrom; ;;
esac
for ((x=nFrom;x<=nTo;x++)); do
sed '/^#/d' > /tmp/d$$_${m}_$((x-nFrom)) <<EOF
{"stopAt":$tl,"n":$nn,
"loadState":"${base}_640K_${x}",
"scenario":[
  "days %3E%3D 151",["gatheringFrequency",$gf1,1],
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],
  "days %3E%3D $rrd3",["gatheringFrequency",$gf3,$rr3],
# Delta variant
  "days %3E%3D $vsd",["infectionProberbility",84.375,$vdd],["vaccineMaxEfficacy",83,$vdd],
# Mass vaccination center starts for younger generations
  "days %3E%3D 183",["vaccinePerformRate",6,14],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 186",["gatheringFrequency",$gf4,1]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative","saveState"]}
EOF
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
