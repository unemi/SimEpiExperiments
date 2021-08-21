#! /bin/bash
nGFs=3
tl=258 # August 31
dir=`pwd | awk -F/ '{print ($NF~/^V_[0-9]_[0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]$/)?$NF:1}'`
if [ $dir = 1 ]; then echo "This script must run on directory V_9_999_99_99"; exit; fi
ld=`echo $dir | awk -F_ '{print $3}'`
st=`echo $dir | awk -F_ '{printf "F095_%s\n",$3}'`
pr=`echo $dir | awk -F_ '{printf "%d\n",$4}'`
vp=`echo $dir | awk -F_ '{print $2}'`
va=`echo $dir | awk -F_ '{print $5}'`
if [ ! -d ../$st ]; then echo "$st does not exist."; exit; fi
if [ $vp -eq 4 ]; then popDist='"popDistMap":"popMap512_1.jpg",'; else popDist=""; fi
if [ $vp -eq 9 ]; then trcOpe='"tracingOperation":2,'; vp=0; else trcOpe=""; fi
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
if [ ! -f ../$st/jobID_$m ]; then echo "$st/jobID_$m does not exist."; exit; fi
jbs=`cat ../$st/jobID_$m`
mj=`echo $jbs | awk '{print NF}'`
if [ $ld = 136 ]; then nj=$nGFs; else nj=$((nn*nGFs)); fi
if [ $mj -ne $nj ]; then echo "$st/jobID_$m should have $nj elements but $mj."; exit; fi
for ((t=0;t<nn;t++)); do
for ((x=1;x<=nGFs;x++)); do
if [ $nj = $nGFs ]; then jb=`echo $jbs | cut -d\  -f$x`; tn=$((t+1));
else jb=`echo $jbs | cut -d\  -f$((t*nGFs+x))`; tn=1; fi
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$tn",$popDist
"params":{"immunity":[400,400,400],$trcOpe
"vaccinePerformRate":$pr,
"vaccinePriority":$vp,
"vaccineAntiRate":$va},
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
done
rm /tmp/s$$
