#! /bin/bash
# gf1=0.55;gf2=0.4;gf3=0.35;gf4=0.7
# gf1=0.55;gf2=0.4;gf3=0.4;gf4=0.7
gf1=0.52;gf2=0.4;gf4=0.7
sz=620
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
# tl=258 # August 31
tl=166 # May 31
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
jb=`cat ../K117/jobID_$m`
for ((x=1;x<=nn;x++)); do
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$x",
"scenario":[
  "days %3E%3D 117",["gatheringFrequency",$gf1,1],["gatheringSize",[10,40,20],1],
  "days %3E%3D 131",["gatheringFrequency",$gf2,4.5],
  "days %3E%3D 145",["vaccinePerformRate",3.3,21],
  "days %3E%3D 151",["gatheringFrequency",$gf4,35]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
#   "days %3E%3D 117",["gatheringFrequency",$gf1,1],["gatheringSize",[10,40,20],1],
#   "days %3E%3D 131",["gatheringFrequency",$gf2,1],
#   "days %3E%3D 134",["gatheringFrequency",$gf3],
#   "days %3E%3D 145",["gatheringFrequency",$gf2],["vaccinePerformRate",3.3,21],
#   "days %3E%3D 151",["gatheringFrequency",$gf4,35]
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
