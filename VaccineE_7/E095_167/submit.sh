#! /bin/bash
nGFs=3
fl=136
tl=167
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
jbs=`cat ../E095_$fl/jobID_$m`
nJbs=`echo $jbs | awk '{print NF}'`
mJbs=`expr $nn \* $nGFs`
if [ $nJbs -ne $mJbs ]; then
	echo "E095_$fl/jobID_$m includes $nJbs jobIDs but not $mJbs."; exit
fi
for ((x=1;x<=nJbs;x++)); do
jb=`echo $jbs | cut -d\  -f$x`
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_1",
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
nw=`wc -w < /tmp/s$$`
if [ $nw -gt 1 ]; then cat /tmp/s$$; exit;
elif [ $nw -eq 0 ]; then
  echo "$m $x $t -- failed `date +%H:%M:%S`."
  sleep $sleepTime
  sleepTime=10
fi
done
echo `cat /tmp/s$$` >> jobID_$m
echo $m $x `cat /tmp/s$$`
done
done
rm /tmp/s$$
