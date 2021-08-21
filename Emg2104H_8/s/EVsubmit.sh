#! /bin/bash
tl=258 # August 31
mbDay=117 # April 12
mbDur=`pwd | awk -F/ '{split($NF,a,"_");print a[2]}'`
vcnDay=`pwd | awk -F/ '{if(split($NF,a,"_")>2)print a[3];else print '$tl'+1}'`
vcnPr=3
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=5; ;;
  simepi2) nn=3; ;;
  *) nn=4; ;;
esac
# April 1, April 7, April 14, 
for x in {0..2}; do
evDay=$((x*7+106))
cat > PL$x <<EOF
job={"stopAt":$tl,"n":$nn,
"loadState":"H106_640K",
"params":{"vaccineAntiRate":30},
"scenario":[
EOF
sort -n > SC <<EOF
$evDay ["infectionProberbility",75,4]
$mbDay ["gatheringFrequency",0.65,1],["mobilityFrequency",[0,60,6]]
$((mbDay+18)) ["gatheringSize",[10,40,20],50],["mobilityFrequency",[0,80,8],50]
$((mbDay+mbDur)) ["gatheringFrequency",1.8,4]
$vcnDay ["vaccinePerformRate",$vcnPr]
EOF
awk '{printf "%s\"days %%3E%%3D %d\",\n%s",(NR>1)?",\n":"",$1,$2}\
END{print "],"}' SC >> PL$x
cat >> PL$x <<EOF
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
#
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ < PL$x
nw=`wc -w < /tmp/s$$`
if [ $nw -gt 1 ]; then cat /tmp/s$$; exit
elif [ $nw -eq 0 ]; then
  echo "$m $x -- failed `date +%H:%M:%S`."
  sleep $sleepTime
  sleepTime=10
fi
done
echo `cat /tmp/s$$` >> jobID_$m
echo $m $x `cat /tmp/s$$`
done
done
rm /tmp/s$$ PL? SC
