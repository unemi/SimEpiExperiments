#! /bin/bash
fl=136
tl=167
pf=".intlab.soka.ac.jp"

submit () {
jb=`awk 'NR=='$2'{print}' ../D095_$fl/jobID_$1`
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$1$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb}_1",
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
nw=`wc -w < /tmp/s$$`
if [ $nw -gt 1 ]; then cat /tmp/s$$; exit;
elif [ $nw -eq 0 ]; then
  echo "$1 $2 $jb -- failed `date +%H:%M:%S`."
  sleep $sleepTime
  sleepTime=10
fi
done
echo `cat /tmp/s$$` >> jobID_$1
echo $1 $2 $jb `cat /tmp/s$$`
}

submit simepiM03 1
submit simepiM05 3

rm /tmp/s$$
