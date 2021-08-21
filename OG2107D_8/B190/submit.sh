#! /bin/bash
base=B150
#gf1=0.27;gf2=0.77;gf3=1.0;rrd2=158;rr2=16;vsd=174;vdd=20
gf1=0.27;gf2=0.43;gf3=0.92;gf4=1.0;rrd2=156;rr2=10;rrd3=167;rr3=5;vsd=174;vdd=20
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
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
sed '/^#/d' <<EOF | curl http://$m$pf/submitJob -s -d @- > /tmp/s$$
job={"stopAt":$tl,"n":$nn,
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
nw=`wc -w < /tmp/s$$`
if [ $nw -gt 1 ]; then cat /tmp/s$$; exit;
elif [ $nw -eq 0 ]; then
  echo "$m $t $x -- failed `date +%H:%M:%S`."
  sleep $sleepTime
  sleepTime=10
fi
done
echo `cat /tmp/s$$` >> jobID_$m
echo $m $x `cat /tmp/s$$`
done
done
rm /tmp/s$$
LANG=C date
