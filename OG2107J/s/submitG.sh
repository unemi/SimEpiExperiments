#! /bin/bash
base=C250
gfAO=1.2
dirName=`pwd | awk -F/ '{print $NF}'`
rrA=3;gfA=`echo $dirName | awk -F_ '{print $2/100*'$gfAO'}'`
rrdA=`echo $dirName | awk -F_ '{print $3}'`
mfA=`echo $gf8 | awk '{x=($1==0.0)?0.01:$1;printf "[0,%.2f,%.2f]\n",x*80,x*20}'`
tl=350 # November 30
# tl=320 # October 31
# tl=289 # September 30
#
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nJobs=1; jbs=(1); nn=(11); ;;
  simepi2) nJobs=1; jbs=(1); nn=(5); ;;
  simepiM00) nJobs=1; jbs=(2); nn=(6); ;;
  simepiM01) nJobs=1; jbs=(2); nn=(6); ;;
  simepiM02) nJobs=2; jbs=(2 3); nn=(4 2); ;;
  simepiM03) nJobs=1; jbs=(3); nn=(6); ;;
  simepiM04) nJobs=1; jbs=(3); nn=(6); ;;
  simepiM05) nJobs=2; jbs=(3 4); nn=(2 4); ;;
  simepiM06) nJobs=1; jbs=(4); nn=(6); ;;
  simepiM07) nJobs=1; jbs=(4); nn=(6); ;;
esac
for ((jbID=0;jbID<nJobs;jbID++)); do
sed '/^#/d' > /tmp/d$$_${m}_$jbID <<EOF
{"stopAt":$tl,"n":${nn[jbID]},
"loadState":"${base}_1M2_${jbs[jbID]}",
"scenario":[
# Emergency measure
  "days %3E%3D $rrdA",["gatheringFrequency",$gfA,$rrA],["mobilityFrequency",$mfA,$rrA],
# Vaccination September 1
  "days %3E%3D 259",["vaccinePerformRate",3.8],
# Vaccination October 1
  "days %3E%3D 289",["vaccinePerformRate",2.8],
# Vaccination November 1
  "days %3E%3D 320",["vaccinePerformRate",1.8]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative","severityStats","saveState"]}
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
fi
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
