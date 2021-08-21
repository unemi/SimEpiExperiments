#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
base=B150
gf1=0.27;gf2=0.77;gf3=1.0;rrd2=158;rr2=16;vsd=174;vdd=20
# D1 gfEL=1.4;gfM2=0.9;gfN0=1.2;gfOG=1.7;gfN1=1.3;gfOB=1.8;gfN2=1.4;gfPG=1.65;gfN3=1.5;gfX=5
gfEL=1.2;gfM2=0.9;gfN0=1.2;gfOG=1.4;gfN1=1.3;gfOB=1.5;gfN2=1.4;gfPG=1.5;gfN3=1.45;gfX=5
#gfEL=1.4;gfM2=1.1;gfN0=1.5;gfOG=1.8;gfN1=1.7;gfOB=2;gfN2=1.9;gfPG=2.1;gfN3=2;gfX=5
tl=349 # November 30
#
# awk '$1<151{print}' ../D1/gatFreq.csv > gatFreq.csv
# echo "151 $gf1" >> gatFreq.csv
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
  "days %3E%3D 186",["gatheringFrequency",$gf3,1],
# Tokyo pref. election from June 25 - July 4
  "days %3E%3D 191",["gatheringFrequency",$gfEL],["mobilityFrequency",[0,80,20]],
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]],
# Lifting restricter measures in July 12
  "days %3E%3D 208",["gatheringFrequency",$gfN0],
# Tokyo Olympic games from July 21 - August 8 & Holiday August 9
  "days %3E%3D 217",["gatheringFrequency",$gfOG],["mobilityFrequency",[0,80,30]],
  "days %3E%3D 237",["gatheringFrequency",$gfN1],["mobilityFrequency",[0,80,8]],
# Summer holidays (Obon) August 13 (Fri) - 16 (Mon)
  "days %3E%3D 240.5",["gatheringFrequency",$gfOB],["mobilityFrequency",[0,80,40]],
  "days %3E%3D 243.5",["gatheringFrequency",$gfN2],["mobilityFrequency",[0,80,8]],
# Tokyo Paralympic games from August 24 - September 5
  "days %3E%3D 251",["gatheringFrequency",$gfPG],
  "days %3E%3D 263",["gatheringFrequency",$gfN3],
# Gradual relaxing of measures
  "days %3E%3D 264",["gatheringFrequency",$gfX,85],["mobilityFrequency",[0,80,30],85]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
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
