#! /bin/bash
base=B116
dd3=117;aa3=0.4;rr3=13
dd4=130;aa4=0.27;rr4=4.5
gf1=0.15;gf2=0.25;rrd2=152;rr2=12
gf3=0.55;rrd3=164;rr3=13;gf4=0.76;rrd4=177;rr4=8
# 
# Days
tl=174
# tl=150
rm -f gatFreq.info
# Size
sz=620
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
jbID=0
for jb in `cat ../$base/jobID_$m`; do
sed '/^#/d' > /tmp/d$$_${m}_$jbID <<EOF
{"stopAt":$tl,"n":1,
"loadState":"${jb}_1",
"scenario":[
# Restricter Measures in April 12.
  "days %3E%3D $dd3",["gatheringFrequency",$aa3,$rr3],["gatheringSize",[10,40,20],$rr3],
# Emergency Declaration (Tokyo, Osaka, ...) in April 25
  "days %3E%3D $dd4",["gatheringFrequency",$aa4,$rr4],
# General vaccination from high-risk citizens
  "days %3E%3D 145",["vaccinePriority",6],["vaccinePerformRate",4,21],
  "days %3E%3D 151",["gatheringFrequency",$gf1,1],
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],
  "days %3E%3D $rrd3",["gatheringFrequency",$gf3,$rr3],
  "days %3E%3D $rrd4",["gatheringFrequency",$gf4,$rr4]
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
fi
jbID=$((jbID+1))
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
