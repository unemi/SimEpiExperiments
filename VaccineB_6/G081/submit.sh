#! /bin/bash
dn=`pwd | awk -F/ '{print $NF}'`
ld=`echo $dn | awk '{printf "%d\n",substr($1,2,3)}'`
st=`(cd ..;echo G???) | awk '{for(i=2;i<=NF;i++)if($i == "'$dn'"){print $(i-1);exit}}'`
gf=0.75
pf=".intlab.soka.ac.jp"
for m in simepi simepi2 simepiM0{0..7}; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$ld,"n":$nn,
"loadState":"$st",
"out":["saveState","asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $m `cat /tmp/s$$`
done
rm /tmp/s$$
