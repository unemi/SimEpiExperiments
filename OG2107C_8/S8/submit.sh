#! /bin/bash
#gf1=0.5;gf2=0.4;gf4=0.7
#gf1=0.3;gf2=0.7;gf3=0.85;rrd2=170;rr2=21
#gf1=0.3;gf2=0.7;gf3=0.85;rrd2=160;rr2=14
#gf1=0.3;gf2=0.7;gf3=0.85;rrd2=155;rr2=10
#gf1=0.3;gf2=0.7;gf3=0.85;rrd2=158;rr2=12
#gf1=0.29;gf2=0.66;gf3=0.95;rrd2=158;rr2=12
gf1=0.29;gf2=0.67;gf3=0.95;rrd2=158;rr2=12
#vsd=175;vdd=30 # Delta variant speading speed
vsd=177;vdd=30 # Delta variant speading speed
# Days
tl=192 # June 26
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
jb=`cat B0/jobId_${m}`
for ((x=1;x<=nn;x++)); do
sed '/^#/d' <<EOF | curl http://$m$pf/submitJob -s -d @- > /tmp/s$$
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$x",
"scenario":[
  "days %3E%3D 151",["gatheringFrequency",$gf1,1],
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],
# Delta variant
  "days %3E%3D $vsd",["infectionProberbility",86,$vdd],["vaccineMaxEfficacy",83,$vdd],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 186",["gatheringFrequency",$gf3,1],
  ],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
done
rm /tmp/s$$
LANG=C date
