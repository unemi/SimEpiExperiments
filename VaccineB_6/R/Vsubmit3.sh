#! /bin/bash
gf=3
if [ `pwd | awk -F/ '{print split($NF,a,"_")}'` -lt 3 ]; then
 echo "This script must run on directory R_G999_999."; exit; fi
tl=258 # August 31
st=`pwd | awk -F/ '{split($NF,a,"_"); printf "%s_%s\n",a[2],a[3]}'`
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
# for cc in fair worse; do
for cc in fair ; do
for x in 1 2 4 8 16; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"loadState":"${st}_0${gf}_$cc",
"params":{"immunity":[400,400,400],
"vaccinePerformRate":$x},
"out":["saveState","asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
done
done
rm /tmp/s$$
