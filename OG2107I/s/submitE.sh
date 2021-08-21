#! /bin/bash
base=B223
dirName=`pwd | awk -F/ '{print $NF}'`
rr8=3;gf8=`echo $dirName | awk -F_ '{print $2/100}'`
rrd8=`echo $dirName | awk -F_ '{print $3}'` # 240
mf8=`echo $gf8 | awk '{x=($1==0.0)?0.01:$1;printf "[0,%.2f,%.2f]\n",x*80,x*20}'`
tl=350 # November 30
# tl=320 # October 31
# tl=289 # September 30
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
# Emergency measure
  "days %3E%3D $rrd8",["gatheringFrequency",$gf8,$rr8],["mobilityFrequency",$mf8,$rr8]
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
