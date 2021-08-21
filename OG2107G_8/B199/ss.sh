#! /bin/bash
base=B150
gf1=0.16;gf2=0.26;rrd2=152;rr2=12
gf3=0.56;rrd3=164;rr3=13;gf4=0.79;rrd4=177;rr4=8;gf5=1.2;rrd5=185;rr5=2
gfEL=1.6;eld=191;els=7;gfM2=2;gfM3=2.3
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
jbID=0
for jb in `cat ../$base/jobID_$m`; do
sed '/^#/d' > /tmp/d$$_${m}_$jbID <<EOF
{"stopAt":$tl,"n":1,
"loadState":"${jb}_1",
"scenario":[
  "days %3E%3D 151",["gatheringFrequency",$gf1,1],
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],
  "days %3E%3D $rrd3",["gatheringFrequency",$gf3,$rr3],
  "days %3E%3D $rrd4",["gatheringFrequency",$gf4,$rr4],
# Delta variant
  "days %3E%3D $vsd",["infectionProberbility",84.375,$vdd],["vaccineMaxEfficacy",83,$vdd],
# Mass vaccination center starts for younger generations
  "days %3E%3D 183",["vaccinePerformRate",6,14],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D $rrd5",["gatheringFrequency",$gf5,$rr5],
  "days %3E%3D $eld",["gatheringFrequency",$gfEL,$els],["mobilityFrequency",[0,80,20],$els],
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
jbID=$((jbID+1))
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
