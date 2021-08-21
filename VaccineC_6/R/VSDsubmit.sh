#! /bin/bash
# Single dose vaccination
# Assumption: 30% after 3 weeks, x% after 3+6 weeks, not expired
#
tl=258 # August 31
dir=`pwd | awk -F/ '{if($(NF-1) ~ /^VSD.*_[0-9][0-9][0-9]_[0-9][0-9][0-9]$/\
 && $NF ~ /^[0-9][0-9]$/)printf "%s_%s\n",$(NF-1),$NF;else print 1}'`
if [ $dir = 1 ]; then echo "This script must run on directory VSD??_999_999/99."; exit; fi
maxEff=`echo $dir | awk -F_ '{printf "%d\n",(length($1)==3)?85:substr($1,4,2)}'`
st=`echo $dir | awk -F_ '{printf "R_%s_%s\n",$2,$3}'`
pr=`echo $dir | awk -F_ '{printf "%d\n",$4}'`
if [ ! -d ../../$st ]; then echo "$st does not exist."; exit; fi
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
if [ ! -f ../../$st/jobID_$m ]; then echo "$st/jobID_$m does not exist."; exit; fi
jbs=`cat ../../$st/jobID_$m`
if [ -z "$jbs" ]; then echo "$st/jobID_$m is empty."; exit; fi
if [ ! -f ../../R_5/$st/jobID_$m ]; then echo "R_5/$st/jobID_$m does not exist."; exit; fi
jbs5=`cat ../../R_5/$st/jobID_$m`
if [ -z "$jbs5" ]; then echo "R_5/$st/jobID_$m is empty."; exit; fi
for ((t=1;t<=$nn;t++)); do
for gf in 4 5 6; do
if [ `echo $jbs | awk '{print NF}'` -le 4 ]; then
case $gf in
  4) jb=`echo $jbs | cut -d\  -f1`; ;;
  5) jb=`echo $jbs5 | cut -d\  -f1`; ;;
  6) jb=`echo $jbs | cut -d\  -f2`; ;;
  *) jb=`echo $jbs | cut -d\  -f3`; ;;
esac
tn=$t
else
case $gf in
  4) jb=`echo $jbs | cut -d\  -f$t`; ;;
  5) jb=`echo $jbs5 | cut -d\  -f$t`; ;;
  6) jn=`expr $nn + $t`; jb=`echo $jbs | cut -d\  -f$jn`; ;;
  *) jn=`expr $nn \* 2 + $t`; jb=`echo $jbs | cut -d\  -f$jn`; ;;
esac
tn=1
fi
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$tn",
"params":{"immunity":[400,400,400],
"vaccineMaxEfficacy":$maxEff,
"vaccineEffectDelay":42,
"vaccinePerformRate":$pr},
"out":["asymptomatic","symptomatic","died",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $m $t $gf `cat /tmp/s$$`
done
done
done
rm /tmp/s$$
