#! /bin/bash
#gf1=0.29;gf2=0.67;gf3=0.95;rrd2=158;rr2=12;vsd=177;vdd=30
#gf1=0.27;gf2=0.68;gf3=0.95;rrd2=158;rr2=10;vsd=176;vdd=25
#gf1=0.26;gf2=0.71;gf3=1.0;rrd2=160;rr2=10;vsd=174;vdd=20
#gf1=0.27;gf2=0.8;gf3=1.0;rrd2=158;rr2=14;vsd=172;vdd=20
gf1=0.27;gf2=0.77;gf3=1.0;rrd2=158;rr2=16;vsd=174;vdd=20
# Days
tl=192 # June 26
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=2; iFrom=1;iN=6; ;;
  simepi2) nn=2; iFrom=7;iN=2; ;;
  *) nn=6; iFrom=`echo $m | awk '{print substr($1,length($1),1)+1}'`;iN=1; ;;
esac
for ((x=0;x<iN;x++)); do
sed '/^#/d' <<EOF | curl http://$m$pf/submitJob -s -d @- > /tmp/s$$
job={"stopAt":$tl,"n":$nn,
"loadState":"B150_640K_$((x+iFrom))",
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
echo $((x+iFrom)) $m `cat /tmp/s$$`
done
done
rm /tmp/s$$
LANG=C date
