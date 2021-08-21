#! /bin/bash
base=B150
rrd1=151;gf1=0.16
rrd2=152;gf2=0.5;rr2=34
rrd4=186;gf4=0.55;rr4=1
rrd5=187;gf5=0.7;rr5=21
rrd6=208;gf6=1.2;rr6=20
vsd1=168;vdd1=32;ipD1=78;idD1=3.3;ve1=89;icMax1=13;ic1=4.5
vsd2=200;vdd2=17;ipD2=81;idD2=3.8;ve2=85;icMax2=11;ic2=4.2
vsd3=217;vdd3=11;ipD3=84.375;idD3=4.8;ve3=83;icMax3=10;ic3=3.7
# Days
tl=228
rm -f gatFreq.info
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
jbID=0
for jb in `cat ../$base/jobID_$m`; do
sed '/^#/d' > /tmp/d$$_${m}_$jbID <<EOF
{"stopAt":$tl,"n":1,
"loadState":"${jb}_1",
"scenario":[
  "days %3E%3D $rrd1",["gatheringFrequency",$gf1,1],
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],["mobilityFrequency",[0,80,20],$rr2],
# Delta variant 1
  "days %3E%3D $vsd1",
  ["infectionProberbility",$ipD1,$vdd1],["infectionDistance",$idD1,$vdd1],
  ["vaccineMaxEfficacy",$ve1,$vdd1],["incubation",[1,$icMax1,$ic1],$vdd1],
# Mass vaccination center starts for younger generations
  "days %3E%3D 183",["vaccinePerformRate",6,14],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D $rrd4",["gatheringFrequency",$gf4,$rr4],
  "days %3E%3D $rrd5",["gatheringFrequency",$gf5,$rr5],
# Delta variant 2
  "days %3E%3D $vsd2",
  ["infectionProberbility",$ipD2,$vdd2],["infectionDistance",$idD2,$vdd2],
  ["vaccineMaxEfficacy",$ve2,$vdd2],["incubation",[1,$icMax2,$ic2],$vdd2],
# Shifting from restricter measures to emergency declaration in July 5
  "days %3E%3D $rrd6",["gatheringFrequency",$gf6,$rr6],
# Vaccination priority change
  ["vaccinePriority",0],
# Delta variant 3
  "days %3E%3D $vsd3",
  ["infectionProberbility",$ipD3,$vdd3],["infectionDistance",$idD3,$vdd3],
  ["vaccineMaxEfficacy",$ve3,$vdd3],["incubation",[1,$icMax3,$ic3],$vdd3]
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
