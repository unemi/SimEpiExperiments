#! /bin/bash
base=B150
gf1=0.27
gf2=0.38;rrd2=152;rr2=12
gf3=1.2;rrd3=164;rr3=17
gf4=1.5;rrd4=2;gfEL=1.9;eld=191;els=6;gfM2=1.7
vsd=174;vdd=50
gfED=0.37;gfEDd=4.5 # 5th emergency declaration
gfEDr=1.2;gfEDrd=17 # relaxing of emergency obedience
bias=2
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
$eld $gf4
$((eld+els)) $gfEL
200 $gfEL
200.1 $gfM2
208 $gfM2
208.1 $gfM2
212.5 $gfED
222 $gfED
239 $gfEDr
EOF
#exit
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
sed '/^#/d' > /tmp/d$$_${m}_$((x-nFrom)) <<EOF
{"stopAt":$tl,"n":$nn,
"loadState":"${base}_640K_${x}",
"scenario":[
  "days %3E%3D 151",["gatheringFrequency",$gf1,1],
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],
  "days %3E%3D $rrd3",["gatheringFrequency",$gf3,$rr3],
# Delta variant
  "days %3E%3D $vsd",["infectionProberbility",84.375,$vdd],["vaccineMaxEfficacy",64,$vdd],
# Mass vaccination center starts for younger generations
  "days %3E%3D 183",["vaccinePerformRate",6,14],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D 186",["gatheringFrequency",$gf4,1],
# Tokyo pref. election from June 25 - July 4
  "days %3E%3D $eld",["gatheringFrequency",$gfEL,$els],["mobilityFrequency",[0,80,20],$els],
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]],
# Shifting from restricter measures to emergency declaration in July 5
  "days %3E%3D 208",["gatheringFrequency",$gfED,$gfEDd],
# Vaccination priority change and speed up from July 12 to 19
  ["vaccinePriority",1],["vaccinePerformRate",$pr,7],
# Relaxing
  "days %3E%3D 222",["gatheringFrequency",$gfEDr,$gfEDrd]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative","saveState"]}
EOF
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
