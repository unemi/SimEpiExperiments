#! /bin/bash
base=B199
dirName=`pwd | awk -F/ '{print $NF}'`
gfM2=2;gfM3=2.3
gfED=`echo $dirName | awk -F_ '{printf "%.4f\n",'$gfM3'*$2/100}'`
gfEDd=4.5 # 5th emergency declaration
gfEDr=$gfM3;gfEDrd=17 # relaxing of emergency obedience
gfN1=$gfM3
tl=350 # November 30
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
  "days %3E%3D 200",["gatheringFrequency",$gfM2],["mobilityFrequency",[0,80,8]],
  "days %3E%3D 201",["gatheringFrequency",$gfM3,7],
# Shifting from restricter measures to emergency declaration in July 5
  "days %3E%3D 208",["gatheringFrequency",$gfED,$gfEDd],
# Vaccination priority change July 12
  ["vaccinePriority",0],
# Relaxing
  "days %3E%3D 222",["gatheringFrequency",$gfEDr,$gfEDrd],
# Lifting in August 23
  "days %3E%3D 250",["gatheringFrequency",$gfN1]
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
      gf=$2;dd=$1+d;printf "%g %g\n",dd,gf}\
    END{printf "%g %g\n",'$tl',gf}' gatFreq.info > gatFreq.csv
#   rm /tmp/d$$_${m}_0
#   exit
fi
jbID=$((jbID+1))
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
