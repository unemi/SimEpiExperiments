#! /bin/bash
tl=258 # August 31
dir=`pwd | awk -F/ '{if($(NF-1) ~ /^V_[0-9]_[0-9][0-9][0-9]$/\
 && $NF ~ /^[0-9][0-9]$/)printf "%s_%s\n",$(NF-1),$NF;else print 1}'`
if [ $dir = 1 ]; then echo "This script must run on directory V_9_999/99."; exit; fi
ld=`echo $dir | awk -F_ '{print $3}'`
st=`echo $dir | awk -F_ '{printf "D095_%s\n",$3}'`
pr=`echo $dir | awk -F_ '{printf "%d\n",$4}'`
vp=`echo $dir | awk -F_ '{print $2}'`
if [ ! -d ../../$st ]; then echo "$st does not exist."; exit; fi
pf=".intlab.soka.ac.jp"
for m in simepi; do
# rm -f jobID_$m
nn=2
if [ ! -f ../../$st/jobID_$m ]; then echo "$st/jobID_$m does not exist."; exit; fi
jbs=`cat ../../$st/jobID_$m`
mj=`echo $jbs | awk '{print NF}'`
if [ $ld = 106 ]; then nj=4; else nj=$(($nn*4)); fi
# if [ $mj -ne $nj ]; then echo "$st/jobID_$m should have $nj elements but $mj."; exit; fi
for ((t=0;t<$nn;t++)); do
for x in 2; do
if [ $nj = 4 ]; then jb=`echo $jbs | cut -d\  -f$x`; tn=$(($t+1));
else jb=`echo $jbs | cut -d\  -f$(($t*4+$x))`; tn=1; fi
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$tn",
"params":{"immunity":[400,400,400],
"vaccinePerformRate":$pr,
"vaccinePriority":$vp},
"out":["asymptomatic","symptomatic","died",
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
echo `cat /tmp/s$$` >> TESTjobID_$m
echo $m $t $x `cat /tmp/s$$`
done
done
done
rm /tmp/s$$
