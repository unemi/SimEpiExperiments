#! /bin/bash
base=B046
# 1 aa1=0.64;rr1=36;aa2=0.9;aa3=0.4;aa4=0.3
aa1=0.68;rr1=36;aa2=1;rr2=15;aa3=0.41;rr3=10;aa4=0.3;rr4=4.5
tl=150
rm -f gatFreq.info
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=22; ;;
  simepi2) nn=10; ;;
  *) nn=12; ;;
esac
jb=`cat ../$base/jobID_$m`
for ((x=0;x<nn;x++)); do
sed '/^#/d' > /tmp/d$$_${m}_$x <<EOF
{"stopAt":$tl,"n":1,
"loadState":"${jb}_$((x+1))",
"scenario":[
  "days %3E%3D 47",["gatheringFrequency",$aa1,$rr1],["gatheringSize",[10,40,20],$rr1],
  ["mobilityFrequency",[0,80,8],$rr1],
# Vaccination starts from Medical workers.
  "days %3E%3D 83",["vaccinePerformRate",0.82,48],
# Lifting emergency delaration in March 21.
  "days %3E%3D 95",["gatheringFrequency",$aa2,$rr2],
# Alpha variant
  "days %3E%3D 110",["infectionProberbility",75,30],
# Restricter Measures in April 12.
  "days %3E%3D 117",["gatheringFrequency",$aa3,$rr3],["gatheringSize",[10,40,20],$rr3],
# Emergency Declaration (Tokyo, Osaka, ...) in April 25
  "days %3E%3D 130",["gatheringFrequency",$aa4,$rr4],
# General vaccination from high-risk citizens
  "days %3E%3D 145",["vaccinePriority",6],["vaccinePerformRate",4,21]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ ! -f gatFreq.info ]; then
  if [ ! -f ../$base/gatFreq.info ]; then
    echo "../$base/gatFreq.info does not exist."; exit; fi
  cp ../$base/gatFreq.info .
  awk '/days %3E/{split($3,a,"\"");d=a[1]}\
  /gatheringFrequency/{n=split($0,a,",");
  for(i=1;i<=n;i++)if(a[i]=="[\"gatheringFrequency\""){\
    gf=a[i+1];\
    if(substr(gf,length(gf),1)=="]"){gf=substr(gf,1,length(gf)-1);gd=0}\
    else gd=substr(a[i+2],1,length(a[i+2])-1);\
    printf "%s %s %s\n",d,gf,gd;break}}' /tmp/d$$_${m}_0 >> gatFreq.info
  awk 'BEGIN{gf=0;dd=0;print "0 0"}\
    {d=$3;if(d==0)d=.1;if(dd<$1)printf "%g %g\n",$1,gf;\
      gf=$2;dd=$1+d;printf "%g %g\n",dd,gf}' gatFreq.info > gatFreq.csv
#   rm /tmp/d$$_${m}_0
#   exit
fi
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
