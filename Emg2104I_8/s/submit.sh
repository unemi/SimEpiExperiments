#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
vp=`echo $dirName | awk -F_ '{printf "%d\n",(NF>1)?$2:-1}'`
pr=`echo $dirName | awk -F_ '{printf "%d\n",(NF>2)?$3:-1}'`
cg=`echo $dirName | awk -F_ '{printf "%d\n",(NF>3)?$4:50}'`
if [ $pr -lt 0 ]; then echo "This script must run from V_9_99_99.";exit;fi
sz=620
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
tl=258 # August 31
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
vpx=$vp
if [ $vp -eq 9 ]; then trcOpe=',["tracingOperation",2]'; vpx=0; else trcOpe=""; fi
if [ $pr -eq 0 -a $cg -eq 0 ]; then crList="60"; else crList="0 20 40 60 80 100"; fi
for cr in $crList; do
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"popDistMap":"popMap200_3.jpg",
"params":{"populationSize":$s,
  "antiVaxClusterGranularity":$cg,"antiVaxClusterRate":$cr,
  "activenessMode":20,"avoidance":70,"fatalityBias":20,
  "friction":40,"gatheringBias":80,
  "gatheringDuration":[3,12,6],"gatheringFrequency":2,
  "gatheringParticipation":[0,100,20],"gatheringSize":[10,40,20],
  "immunity":[400,400,400],"incubation":[2,20,7],"incubationBias":20,
  "infectionProberbility":50,"mobilityBias":80,
  "quarantineAsymptomatic":3,"quarantineSymptomatic":70,
  "subjectAsymptomatic":0,"subjectSymptomatic":50,
  "vaccineEffectPeriod":100,"vaccinePerformRate":0,
  "workPlaceMode":3},
"scenario":[
  "days %3E%3D 1",["gatheringFrequency",11,3],
  "days %3E%3D 9",["gatheringFrequency",0.01],["gatheringSize",[4,16,8]],
  ["mobilityFrequency",[0,80,8]],["backHomeRate",50],
  "days %3E%3D 16",["gatheringFrequency",2],["mobilityFrequency",[0,70,7]],
  ["backHomeRate",75],
  "days %3E%3D 22",["gatheringFrequency",0.19,0.5],["mobilityFrequency",[0,60,6]],
  "days %3E%3D 40",["gatheringFrequency",0.62,37],["gatheringSize",[10,40,20],37],
  ["mobilityFrequency",[0,80,8],37],
  "days %3E%3D 95",["gatheringFrequency",1.2,14],
  "days %3E%3D 117",["infectionProberbility",68,21],["gatheringFrequency",0.8,0.5],
  "days %3E%3D 130",["gatheringFrequency",0.5,0.5],["mobilityFrequency",[0,60,6],0.5],
  "days %3E%3D 136",["vaccinePerformRate",$pr],["vaccinePriority",$vpx]$trcOpe,
  "days %3E%3D 146",["gatheringFrequency",1.2,2],["gatheringSize",[10,40,20],2]],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
EOF
nw=`wc -w < /tmp/s$$`
if [ $nw -gt 1 ]; then cat /tmp/s$$; exit;
elif [ $nw -eq 0 ]; then
  echo "$m $t $x -- failed `date +%H:%M:%S`."
  sleep $sleepTime
  sleepTime=10
fi
done
echo `cat /tmp/s$$` >> jobID_$m
echo $m $cr `cat /tmp/s$$`
done
done
rm /tmp/s$$
