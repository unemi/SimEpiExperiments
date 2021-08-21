#! /bin/bash
tl=136
dir=`pwd | awk -F/ '{if($NF ~ /^R_[0-9][0-9][0-9]_'$tl'$/)print $NF;else print 1}'`
if [ $dir = 1 ]; then echo "This script must run on directory R_999_136."; exit; fi
s=`pwd | awk -F/ '{split($NF,a,"_"); print a[2]}'`
st="R_${s}_106"
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
jbs=`cat ../$st/jobID_$m`
nJbs=`echo $jbs | awk '{print NF}'`
if [ $nJbs -ne 4 ]; then
	echo "$st/jobID_$m includes $nJbs jobIDs but not 4."; exit
fi
for x in {1..4}; do
jb=`echo $jbs | cut -d\  -f$x`
for ((t=1;t<=$nn;t++)); do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$t",
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $m $x $t `cat /tmp/s$$`
done
done
done
rm /tmp/s$$
