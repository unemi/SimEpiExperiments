#! /bin/bash
if [ `pwd | awk -F/ '{print split($NF,a,"_")}'` -lt 3 ]; then
 echo "This script must run on directory R_999_999."; exit; fi
tl=`pwd | awk -F/ '{split($NF,a,"_"); print a[3]}'`
if [ "$tl" != 106 ]; then echo "This command should run from R_???_106."; exit; fi
st=`pwd | awk -F/ '{split($NF,a,"_"); print a[2]}'`
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
for x in {0..3}; do
gf=`expr $x \* 2 + 4`
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"loadState":"C${st}_fair",
"params":{"gatheringFrequency":$gf},
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
done
rm /tmp/s$$
