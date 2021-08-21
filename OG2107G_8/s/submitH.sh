#! /bin/bash
base=B249
gfEDr=1.2;gfEDrd=17 # relaxing of emergency obedience
dirName=`pwd | awk -F/ '{print $NF}'`
# if [ `echo $dirName | awk -F_ '{print NF}'` -lt 3 ]; then
#   echo "$dirName is not in a form of X_bias_pr."; exit; fi
pr=6
gfN1=1.7;gfPG=1.9
gfN3=`echo $dirName | awk -F_ '{printf "%.1f\n",$2*.1}'`
xDay=320 # December 1
xDayD=7
gfX=5
antiVaxRate=`echo $dirName | awk -F_ '{printf "%d\n",(NF>2)?$3:30}'`
tl=411 # January 31
#
cp -f ../$base/gatFreq.csv gatFreq.csv
cat >> gatFreq.csv << EOF
250 $gfEDr
250.1 $gfN1
251 $gfN1
251.1 $gfPG
263 $gfPG
263.1 $gfN3
$xDay $gfN3
$((xDay+xDayD)) $gfX
372 $gfX
375 9.5
381 9.5
381.1 0.01
384 0.01
384.1 $gfX
$tl $gfX
EOF
#
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nn=2; ;;
  simepi2) nn=2; ;;
  *) nn=6; ;;
esac
nJobs=0
for jb in `cat ../$base/jobID_$m`; do
for ((tsk=1;tsk<=nn;tsk++)); do
sed '/^#/d' > /tmp/d$$_${m}_$nJobs <<EOF
{"stopAt":$tl,"n":1,"loadState":"${jb}_$tsk",
"scenario":[
# Lifting in August 23
  "days %3E%3D 250",["gatheringFrequency",$gfN1],
  ["vaccineAntiRate",$antiVaxRate],
# Tokyo Paralympic games from August 24 - September 5
  "days %3E%3D 251",["gatheringFrequency",$gfPG],
  "days %3E%3D 263",["gatheringFrequency",$gfN3],
  "days %3E%3D $xDay",["gatheringFrequency",$gfX,$xDayD],["mobilityFrequency",[0,80,30],$xDayD],
# Christmass eve
  "days %3E%3D 372",["gatheringFrequency",9.5,3],
# New year 2022
  "days %3E%3D 381",["gatheringFrequency",0.01],["gatheringSize",[4,16,8]],
  ["mobilityFrequency",[0,80,8]],["backHomeRate",50],
# Office opening
  "days %3E%3D 384",["gatheringFrequency",$gfX],["mobilityFrequency",[0,70,7]],
  ["backHomeRate",75]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
EOF
nJobs=$((nJobs+1))
done
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
