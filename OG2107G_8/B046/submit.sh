#! /bin/bash
gf1=0.27
gf2=0.4;rrd2=152;rr2=12
gf3=0.95;rrd3=164;rr3=14;gf4=1.25;rrd4=178;rr4=8;gf5=1.6;rrd5=186;rr5=1
gfEL=2.2;eld=191;els=7;gfM2=2.15;gfM3=3;gfED=2.4;vdd=50
vsd=174
# Days
tl=46
# Size
sz=620
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=22; ;;
  simepi2) nn=10; ;;
  *) nn=12; ;;
esac
sed '/^#/d' > /tmp/d$$_${m}_0 <<EOF
{"stopAt":$tl,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "activenessMode":20,"antiVaxTestRate":100,"avoidance":70,
  "fatalityBias":20,"friction":40,
  "gatheringBias":80,"gatheringDuration":[3,12,6],"gatheringFrequency":1.2,
  "gatheringParticipation":[0,100,20],"gatheringSize":[10,40,20],
  "incubation":[2,20,7],"incubationBias":20,
  "infectionProberbility":50,"mobilityBias":80,
  "quarantineAsymptomatic":3,"quarantineSymptomatic":70,
  "subjectAsymptomatic":0,"subjectSymptomatic":50,
  "vaccineEffectPeriod":200,"vaccinePerformRate":0,"workPlaceMode":3},
"scenario":[
  "days %3E%3D 1",["gatheringFrequency",9.5,3],
  "days %3E%3D 10",["gatheringFrequency",0.01],["gatheringSize",[4,16,8]],
  ["mobilityFrequency",[0,80,8]],["backHomeRate",50],
  "days %3E%3D 16",["gatheringFrequency",2],["mobilityFrequency",[0,70,7]],
  ["backHomeRate",75],
# Emergency Declaration in January 7.
  "days %3E%3D 22",["gatheringFrequency",0.52,1],["mobilityFrequency",[0,60,6]]
  ],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative","saveState"]}
EOF
if [ ! -f gatFreq.info ]; then
  awk '/days %3E/{split($3,a,"\"");d=a[1]}\
  /gatheringFrequency/{n=split($0,a,",");
  for(i=1;i<=n;i++)if(a[i]=="[\"gatheringFrequency\""){\
    gf=a[i+1];\
    if(substr(gf,length(gf),1)=="]"){gf=substr(gf,1,length(gf)-1);gd=0}\
    else gd=substr(a[i+2],1,length(a[i+2])-1);\
    printf "%s %s %s\n",d,gf,gd;break}}' /tmp/d$$_${m}_0 > gatFreq.info
fi
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
