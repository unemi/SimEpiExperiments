#! /bin/bash
s=`pwd | awk '{print substr($0,length($0),1)}' |\
 awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n",\
  $1*$1, $1*500, $1*25, $1*$1}'`
gf=12
st=91rmh3Auzh9_8
tl=`pwd | cut -d_ -f2`
pf=".intlab.soka.ac.jp"
m=simepi
rm -f jobID_$m
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":20,
"loadState":"$st",
"out":["saveState",
"asymptomatic","symptomatic","recovered","died","vaccinated",
"dailyTests","dailyTestPositive","dailyTestNegative",
"incubasionPeriod","recoveryPeriod","fatalPeriod","infects"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobID_$m
echo $x $mb `cat /tmp/s$$`
rm /tmp/s$$
