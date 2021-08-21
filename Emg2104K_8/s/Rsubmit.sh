#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
base=`echo $dirName | awk -F_ '{printf "%s166\n",$1}'`
if [ ! -d $base ]; then base=K166; fi
gf=`echo $dirName | awk -F_ '{printf "%.2f\n",((NF>1)?$2:10)*0.11}'`
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
jb=(`cat ../$base/jobID_$m`)
for ((x=0;x<nn;x++)); do
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb[x]}_1",
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
