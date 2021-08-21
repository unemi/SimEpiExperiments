#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
base=C186
#gfM1=0.8;gfEL=0.9;gfM2=0.8;gfN0=1.1;gfOG=1.2;gfN1=1.1;gfOB=1.2;gfN2=1.1;gfPG=1.15;gfN3=1.1;gfX=5
#gfM1=0.9;gfEL=1.0;gfM2=0.9;gfN0=1.2;gfOG=1.4;gfN1=1.3;gfOB=1.5;gfN2=1.4;gfPG=1.45;gfN3=1.5;gfX=5
gfM1=0.9;gfEL=1.4;gfM2=0.9;gfN0=1.2;gfOG=1.7;gfN1=1.3;gfOB=1.8;gfN2=1.4;gfPG=1.65;gfN3=1.5;gfX=5
tl=349 # November 30
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
"loadState":"C186_640K_${x}",
"scenario":[
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 187",["gatheringFrequency",$gfM1,1],
# Delta variant
  "days %3E%3D 188",["infectionProberbility",86,40],["vaccineMaxEfficacy",83,40],
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
