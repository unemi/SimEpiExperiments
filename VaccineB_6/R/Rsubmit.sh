#! /bin/bash
if [ `pwd | awk -F/ '{print split($NF,a,"_")}'` -lt 3 ]; then
 echo "This script must run on directory R_G999_999."; exit; fi
tl=`pwd | awk -F/ '{split($NF,a,"_"); print a[3]}'`
st=`pwd | awk -F/ '{split($NF,a,"_"); print a[2]}'`
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
for x in {2..4}; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"loadState":"$st",
"params":{"gatheringFrequency":$x},
"out":["saveState","asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
done
rm /tmp/s$$
