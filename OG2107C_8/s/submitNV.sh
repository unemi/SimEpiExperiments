#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
base=B190
gf1=0.27;gf2=0.77;gf3=1.0;rrd2=158;rr2=16;vsd=174;vdd=20
# D1 gfEL=1.4;gfM2=0.9;gfN0=1.2;gfOG=1.7;gfN1=1.3;gfOB=1.8;gfN2=1.4;gfPG=1.65;gfN3=1.5;gfX=5
dirName=`pwd | awk -F/ '{print $NF}'`
if [ `echo $dirName | awk -F_ '{print NF}'` -lt 4 ]; then
  echo "$dirName is not in a form of X_relx_bias_normal."; exit; fi
#gfEL=1.2;gfM2=0.9;gfN0=1.2;gfOG=1.4;gfN1=1.3;gfOB=1.5;gfN2=1.4;gfPG=1.5;gfN3=1.45
gfEL=`echo $dirName | awk -F_ '{print '$gf3'+$3*.1}'`
gfM2=`echo $dirName | awk -F_ '{print '$gf3'+$2*.1}'`
gfN0=`echo $dirName | awk -F_ '{print '$gfM2'+$4*.1}'`
gfOG=`echo $dirName | awk -F_ '{print '$gfN0'+$3*.1}'`
gfN1=`echo $dirName | awk -F_ '{print '$gfN0'+$2*.1}'`
gfOB=`echo $dirName | awk -F_ '{print '$gfN1'+$3*.1}'`
gfN2=`echo $dirName | awk -F_ '{print '$gfN1'+$2*.1}'`
gfPG=`echo $dirName | awk -F_ '{print '$gfN2'+$3*.05}'`
gfN3=`echo $dirName | awk -F_ '{print '$gfN2'+$2*.1}'`
gfX=5
#tl=349 # November 30
tl=380 # December 31
#
awk '$1<151{print}' ../D1/gatFreq.csv > gatFreq.csv
cat >> gatFreq.csv << EOF
151 $gf1
$rrd2 $gf1
$((rrd2+rr2)) $gf2
186 $gf2
187 $gf3
191 $gf3
191.1 $gfEL
200 $gfEL
200.1 $gfM2
208 $gfM2
208.1 $gfN0
217 $gfN0
217.1 $gfOG
237 $gfOG
237.1 $gfN1
240.5 $gfN1
240.6 $gfOB
243.5 $gfOB
243.6 $gfN2
251 $gfN2
251.1 $gfPG
263 $gfPG
263.1 $gfN3
264 $gfN3
$((264+85)) $gfX
$tl $gfX
EOF
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nTasks=2; ;;
  simepi2) nTasks=2; ;;
  *) nTasks=6; ;;
esac
for jb in `cat ../$base/jobID_$m`; do
for ((x=1;x<=nTasks;x++)); do
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
sed '/^#/d' <<EOF | curl http://$m$pf/submitJob -s -d @- > /tmp/s$$
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_${x}",
"params":{"vaccinePerformRate":0},
"scenario":[
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
echo $m $jb $x `cat /tmp/s$$`
done
done
done
rm /tmp/s$$
LANG=C date
