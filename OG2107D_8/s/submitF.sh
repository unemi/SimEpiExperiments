#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
base=B190
gf1=0.27;gf2=0.43;gf3=0.92;gf4=1.0;rrd2=156;rr2=10;rrd3=167;rr3=5;vsd=174;vdd=20
gfED=0.37;gfEDd=4.5 # 5th emergency declaration
gfEDr=0.7;gfEDrd=21 # relaxing of emergency cooperation
dirName=`pwd | awk -F/ '{print $NF}'`
if [ `echo $dirName | awk -F_ '{print NF}'` -lt 3 ]; then
  echo "$dirName is not in a form of X_bias_pr."; exit; fi
bias=`echo $dirName | awk -F_ '{print $2}'`
pr=`echo $dirName | awk -F_ '{printf "%d\n",$3}'`
gfEL=`echo $bias | awk -F_ '{print '$gf4'+$1*.2}'`
gfM2=`echo $bias | awk -F_ '{print '$gf4'+$1*.1}'`
gfN1=`echo $bias | awk -F_ '{print '$gf4'+$1*.2}'`
gfPG=`echo $bias | awk -F_ '{print '$gfN1'+$1*.1}'`
gfN3=`echo $bias | awk -F_ '{print '$gfN1'+$1*.1}'`
gfX=5
#tl=349 # November 30
tl=380 # December 31
#
awk '$1<151{print}' ../../OG2107C_8/D1/gatFreq.csv > gatFreq.csv
cat >> gatFreq.csv << EOF
151 $gf1
$rrd2 $gf1
$((rrd2+rr2)) $gf2
$rrd3 $gf2
$((rrd3+rr3)) $gf3
186 $gf3
187 $gf4
191 $gf4
191.1 $gfEL
200 $gfEL
200.1 $gfM2
208 $gfM2
208.1 $gfM2
212.5 $gfED
222 $gfED
243 $gfEDr
243.5 $gfEDr
250 $gfEDr
250.1 $gfN1
251 $gfN1
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
"scenario":[
# Tokyo pref. election from June 25 - July 4
  "days %3E%3D 191",["gatheringFrequency",$gfEL],["mobilityFrequency",[0,80,20]],
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]],
# Shifting from restricter measures to emergency declaration in July 5
  "days %3E%3D 208",["gatheringFrequency",$gfED,$gfEDd],
# Vaccination priority change and speed up from July 12 to 19
  ["vaccinePriority",1],["vaccinePerformRate",$pr,7],
# Relaxing
  "days %3E%3D 222",["gatheringFrequency",$gfEDr,$gfEDrd],
# Lifting in August 23
  "days %3E%3D 250",["gatheringFrequency",$gfN1],
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
