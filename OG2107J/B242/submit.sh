#! /bin/bash
base=B199
# rrd6=208;gf6=0.6;rr6=10
# rrd7=218;gf7=1.2;rr7=20
# rrd8=238;gf8=0.8;rr8=2
# vsd2=200;vdd2=18;ipD2=81;idD2=3.8;ve2=85;icMax2=11;ic2=4.2
# vsd3=218;vdd3=7;ipD3=84.375;idD3=4.2;ve3=83;icMax3=10;ic3=3.7
# 
# rrd6=208;gf6=0.8;rr6=10
# rrd7=218;gf7=1.2;rr7=20
# rrd8=238;gf8=1;rr8=2
# vsd2=200;vdd2=18;ipD2=81;idD2=3.9;ve2=85;icMax2=11;ic2=4.2
# vsd3=218;vdd3=7;ipD3=84.375;idD3=4.2;ve3=83;icMax3=10;ic3=3.7
# 
# rrd6=208;gf6=0.8;rr6=10
# rrd7=218;gf7=1.2;rr7=20
# rrd8=238;gf8=1;rr8=2
# vsd3=214;vdd3=7;ipD3=84.375;idD3=4.2;ve3=83;icMax3=10;ic3=3.7
#
rrd6=208;gf6=0.8;rr6=10
rrd7=218;gf7=1.2;rr7=20
rrd8=238;gf8=1;rr8=2
vsd3=215;vdd3=7;ipD3=85;idD3=4.4;ve3=83;icMax3=10;ic3=3.7
#
# Days
tl=242
rm -f gatFreq.info
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nJobs=1; nn=(11); ;;
  simepi2) nJobs=1; nn=(5); ;;
  simepiM00) nJobs=1; nn=(6); ;;
  simepiM01) nJobs=1; nn=(6); ;;
  simepiM02) nJobs=2; nn=(4 2); ;;
  simepiM03) nJobs=1; nn=(6); ;;
  simepiM04) nJobs=1; nn=(6); ;;
  simepiM05) nJobs=2; nn=(2 4); ;;
  simepiM06) nJobs=1; nn=(6); ;;
  simepiM07) nJobs=1; nn=(6); ;;
esac
jbX=0
jbs=(`cat ../$base/jobID_$m`)
for ((jbID=0;jbID<nJobs;jbID++)); do
for ((trID=1;trID<=${nn[jbID]};trID++)); do
sed '/^#/d' > /tmp/d$$_${m}_$jbX <<EOF
{"stopAt":$tl,"n":1,
"loadState":"${jbs[jbID]}_$trID",
"scenario":[
# Shifting from restricter measures to emergency declaration in July 5
  "days %3E%3D $rrd6",["gatheringFrequency",$gf6,$rr6],
# Vaccination priority change
  ["vaccinePriority",0],
# Delta variant 3
  "days %3E%3D $vsd3",
  ["infectionProberbility",$ipD3,$vdd3],["infectionDistance",$idD3,$vdd3],
  ["vaccineMaxEfficacy",$ve3,$vdd3],["incubation",[1,$icMax3,$ic3],$vdd3],
  ["contagionDelay",0.35,$vdd3],["contagionPeak",2.1,$vdd3],
# relaxing
  "days %3E%3D $rrd7",["gatheringFrequency",$gf7,$rr7],
# Vaccination August 1
  "days %3E%3D 228",["vaccinePerformRate",4.8],
# Obon (empty Tokyo)
  "days %3E%3D $rrd8",["gatheringFrequency",$gf8,$rr8]
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
    END{if(dd<'$tl')printf "%d %g\n",'$tl',gf}' gatFreq.info > gatFreq.csv
fi
jbX=$((jbX+1))
done
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
