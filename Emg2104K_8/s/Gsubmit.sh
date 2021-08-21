#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
gf=`echo $dirName | awk -F_ '{printf "%.2f\n",((NF>1)?$2:10)*0.11}'`
sz=620
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
tl=258 # August 31
pf=".intlab.soka.ac.jp"
for mx in {0..7}; do
m=simepiM0$mx
rm -f jobID_$m
for x in 1 2; do
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":4,
"loadState":"F166_640K_$((mx*2+x))",
"scenario":[
  "days %3E%3D 166",["vaccinePerformRate",4,30],
  "days %3E%3D 186",["gatheringFrequency",$gf,2],["mobilityFrequency",[0,80,8],2]
],
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
echo $m $x `cat /tmp/s$$`
done
done
rm /tmp/s$$
LANG=C date
