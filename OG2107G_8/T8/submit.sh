#! /bin/bash
gf1=0.27
gf2=0.4;rrd2=152;rr2=12
# gf3=0.8;rrd3=164;rr3=14;gf4=1.2;rrd4=178;rr4=8;gf5=1.5;rrd5=186;rr5=1
# gfEL=2.3;eld=191;els=7;gfM2=2.2;gfM3=2.8;gfED=2;vdd=50
gf3=0.95;rrd3=164;rr3=14;gf4=1.25;rrd4=178;rr4=8;gf5=1.6;rrd5=186;rr5=1
#gfEL=2.3;eld=191;els=7;gfM2=2.2;gfM3=3;gfED=2.4;vdd=50
gfEL=2.2;eld=191;els=7;gfM2=2.15;gfM3=3;gfED=2.4;vdd=50
vsd=174
# Days
tl=219 # July 23
awk '$1<151{print}' ../../OG2107C_8/D1/gatFreq.csv > gatFreq.csv
cat >> gatFreq.csv << EOF
151 $gf1
$rrd2 $gf1
$((rrd2+rr2)) $gf2
$rrd3 $gf2
$((rrd3+rr3)) $gf3
$rrd4 $gf3
$((rrd4+rr4)) $gf4
$rrd5 $gf4
$((rrd5+rr5)) $gf5
$eld $gf5
$((eld+els)) $gfEL
200 $gfEL
200.1 $gfM2
208 $gfM3
212.5 $gfED
$tl $gfED
EOF
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
  "days %3E%3D $rrd5",["gatheringFrequency",$gf5,$rr5],
  "days %3E%3D $eld",["gatheringFrequency",$gfEL,$els],["mobilityFrequency",[0,80,20],$els],
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]],
  ["gatheringFrequency",$gfM3,8],
  "days %3E%3D 208",["gatheringFrequency",$gfED,4.5]
  ],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
EOF
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
