#! /bin/bash
base=B150
rrd1=151;gf1=0.27;rr1=10
rrd2=170;gf2=0.58;rr2=16
rrd4=186;gf4=0.73;rr4=1
rrd5=187;gf5=0.93;rr5=21
# vsd1=164;vdd1=30;ipD1=78;idD1=3.5;ve1=89;icMax1=13;ic1=4.5
# vsd2=194;vdd2=21;ipD2=81;idD2=3.9;ve2=85;icMax2=11;ic2=4.2
vsd1=162;vdd1=31;ipD1=78;idD1=3.5;ve1=89;icMax1=13;ic1=4.5
vsd2=193;vdd2=22;ipD2=81;idD2=3.9;ve2=85;icMax2=11;ic2=4.2
# Days
tl=199
rm -f gatFreq.info
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
  "days %3E%3D $rrd1",["gatheringFrequency",$gf1,$rr1],
# Delta variant 1
  "days %3E%3D $vsd1",
  ["infectionProberbility",$ipD1,$vdd1],["infectionDistance",$idD1,$vdd1],
  ["vaccineMaxEfficacy",$ve1,$vdd1],["incubation",[1,$icMax1,$ic1],$vdd1],
  ["contagionDelay",0.45,$vdd1],["contagionPeak",2.7,$vdd1],
# relaxing
  "days %3E%3D $rrd2",["gatheringFrequency",$gf2,$rr2],["mobilityFrequency",[0,80,20],$rr2],
# Mass vaccination center starts for younger generations
  "days %3E%3D 183",["vaccinePerformRate",6,14],
# Shifting from declaration to restricter measures in June 21.
  "days %3E%3D $rrd4",["gatheringFrequency",$gf4,$rr4],
  "days %3E%3D $rrd5",["gatheringFrequency",$gf5,$rr5],
# Delta variant 2
  "days %3E%3D $vsd2",
  ["infectionProberbility",$ipD2,$vdd2],["infectionDistance",$idD2,$vdd2],
  ["vaccineMaxEfficacy",$ve2,$vdd2],["incubation",[1,$icMax2,$ic2],$vdd2],
  ["contagionDelay",0.38,$vdd2],["contagionPeak",2.2,$vdd2],
# Vaccination July 1
  "days %3E%3D 197",["vaccinePerformRate",5.8]
  ],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative","saveState"]}
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
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
