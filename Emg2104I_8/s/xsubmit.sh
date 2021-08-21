#! /bin/bash
pr=`pwd | awk -F/ '{n=split($NF,a,"_");print (n>1)?a[2]:-1}'`
if [ $pr -lt 0 ]; then echo "This script must run from V_[9].";exit;fi
tl=258 # August 31
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
if [ $pr -eq 0 ]; then vpList=(0); else vpList=(0 1 4 9); fi
for x in ${vpList[@]}; do vp=$x
if [ $x -eq 4 ]; then popDist='"popDistMap":"popMap200_3.jpg",'; else popDist=""; fi
if [ $x -eq 9 ]; then trcOpe='"tracingOperation":2,'; vp=0; else trcOpe=""; fi
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"loadState":"I131_640K",$popDist
"params":{"immunity":[400,400,400],$trcOpe
"vaccinePerformRate":$pr,
"vaccinePriority":$vp},
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
echo $m $t $x `cat /tmp/s$$`
done
done
rm /tmp/s$$
