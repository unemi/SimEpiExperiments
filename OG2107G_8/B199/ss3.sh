#! /bin/bash
base=B199
gfM2=2;gfM3=2.3
gfED=2.1;gfEDd=4.5
# 
vsd=174;vdd=50
# Days
tl=222 # July 26
# rm -f gatFreq.info
# Size
sz=620
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
#
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
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
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]],
  "days %3E%3D 201",["gatheringFrequency",$gfM3,8],
# Shifting from restricter measures to emergency declaration in July 5
  "days %3E%3D 208",["gatheringFrequency",$gfED,$gfEDd],
# Vaccination priority change
  ["vaccinePriority",1]
  ],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
EOF
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
