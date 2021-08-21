#! /bin/bash
dir=`pwd | awk -F/ '{if($NF ~ /^C[0-9][0-9][0-9]$/)print $NF;else print 1}'`
if [ $dir = 1 ]; then echo "This command must run from C???."; exit; fi
st=`(cd ..;echo C???)| awk '{for(i=2;i<=NF;i++)if($i=="'$dir'"){print $(i-1);exit}}'`
if [ -z "$st" ]; then echo "This command must run from another C??? than $dir."; exit; fi
tl=`echo $dir | awk '{printf "%d\n",substr($1,2,3)}'`
# echo $dir $st $tl
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
jb=`head -1 ../$st/jobID_$m`
for ((t=1;t<=$nn;t++)); do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_$t",
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; echo ""; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $m $t `cat /tmp/s$$`
done
done
rm /tmp/s$$
