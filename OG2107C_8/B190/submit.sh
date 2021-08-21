#! /bin/bash
base=B150
gf1=0.27;gf2=0.77;gf3=1.0;rrd2=158;rr2=16;vsd=174;vdd=20
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
# Delta variant
  "days %3E%3D $vsd",["infectionProberbility",86,$vdd],["vaccineMaxEfficacy",83,$vdd],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 186",["gatheringFrequency",$gf3,1]
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
