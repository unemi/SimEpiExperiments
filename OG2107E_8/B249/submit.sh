#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
base=B190
gf1=0.27;gf2=0.38;rrd2=152;rr2=12;gf3=1.1;rrd3=164;rr3=17
gf4=1.3;rrd4=2;gfEL=1.6;eld=191;els=7;gfM2=1.4;vsd=174;vdd=30
gfED=0.37;gfEDd=4.5 # 5th emergency declaration
gfEDr=1.2;gfEDrd=17 # relaxing of emergency obedience
# dirName=`pwd | awk -F/ '{print $NF}'`
# if [ `echo $dirName | awk -F_ '{print NF}'` -lt 3 ]; then
#   echo "$dirName is not in a form of X_bias_pr."; exit; fi
bias=2
# pr=`echo $dirName | awk -F_ '{printf "%d\n",$3}'`
pr=6
gfN1=`echo $bias | awk -F_ '{print '$gf4'+$1*.2}'`
gfPG=`echo $bias | awk -F_ '{print '$gfN1'+$1*.1}'`
gfN3=`echo $bias | awk -F_ '{print '$gfN1'+$1*.1}'`
tl=249 # August 22
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
239 $gfEDr
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
nJobs=0
for jb in `cat ../$base/jobID_$m`; do
for ((x=1;x<=nTasks;x++)); do
sed '/^#/d' > /tmp/d$$_${m}_$nJobs <<EOF
{"stopAt":$tl,"n":1,"loadState":"${jb}_${x}",
"scenario":[
# Tokyo pref. election from June 25 - July 4
  "days %3E%3D 191",["gatheringFrequency",$gfEL],["mobilityFrequency",[0,80,20]],
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]],
# Shifting from restricter measures to emergency declaration in July 5
  "days %3E%3D 208",["gatheringFrequency",$gfED,$gfEDd],
# Vaccination priority change and speed up from July 12 to 19
  ["vaccinePriority",1],["vaccinePerformRate",$pr,7],
# Relaxing
  "days %3E%3D 222",["gatheringFrequency",$gfEDr,$gfEDrd]
],
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
nJobs=$((nJobs+1))
done
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
