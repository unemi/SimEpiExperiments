#! /bin/bash
tl=258 # August 31
vd=167
xn=3
st="E095_167"
if [ ! -d ../$st ]; then echo "$st does not exist."; exit; fi
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
nj=$((nn*xn))
if [ $mj -ne $nj ]; then echo "$st/jobID_$m should have $nj elements but $mj."; exit; fi
for ((t=0;t<nn;t++)); do
for ((x=1;x<=xn;x++)); do
jb=`echo $jbs | cut -d\  -f$((t*xn+x))`; tn=1
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$tn",
"params":{"immunity":[400,400,400]},
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
echo `cat /tmp/s$$` >> jobID_$m
echo $m $t $x `cat /tmp/s$$`
done
done
done
rm /tmp/s$$
