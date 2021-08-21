#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
base=../Emg2104K_8/F166
rd3=`echo $dirName | awk -F_ '{print ((NF>3)?$4:0)+186}'`
bias=`echo $dirName | awk -F_ '{print (NF>2)?$3:10}'`
gf=(`echo $dirName | awk -F_ '{d=(NF>1)?$2:1;for(i=1;i<=4;i++)printf "%.1f ",i*d/10+1.1}'`)
# echo ${gf[@]}
# exit
gfX=5
gfE=`echo $bias | awk '{printf "%.2f\n",$1/10*'${gf[0]}'}'`
gfO=`echo $bias | awk '{printf "%.2f\n",$1/10*'${gf[1]}'}'`
gfP=`echo $bias | awk '{printf "%.2f\n",(($1/10-1)/2+1)*'${gf[2]}'}'`
gfEE=`echo $bias | awk '{printf "%.5f\n",$1/10*0.7}'`
gf1E=`echo ${gf[1]} | awk '{printf "%.5f\n",$1*0.7/1.1}'`
sz=620
s=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);\
  printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", n*n, n*'$sz', n*25}'`
tl=349 # November 30
#
# in ../../Emg2104K_8/F166/submit.sh
# gf1=0.52;gf2=0.4;gf4=0.7
#  "days %3E%3D 131",["gatheringFrequency",$gf2,4.5],
#  "days %3E%3D 151",["gatheringFrequency",$gf4,35]
#
if [ $rd3 -lt 191 ]; then cat > /tmp/e$$ <<EOF
  "days %3E%3D $rd3",["gatheringFrequency",${gf[0]},2],["mobilityFrequency",[0,80,8],2],
  "days %3E%3D 191",["gatheringFrequency",$gfE],["mobilityFrequency",[0,80,20]],
  "days %3E%3D 200",["gatheringFrequency",${gf[1]}],["mobilityFrequency",[0,80,8]],
EOF
elif [ $rd3 -lt 200 ]; then cat > /tmp/e$$ <<EOF
  "days %3E%3D 191",["gatheringFrequency",$gfEE],["mobilityFrequency",[0,80,20]],
  "days %3E%3D $rd3",["gatheringFrequency",${gf[0]},2],["mobilityFrequency",[0,80,8],2],
  "days %3E%3D 200",["gatheringFrequency",${gf[1]}],["mobilityFrequency",[0,80,8]],
EOF
else cat > /tmp/e$$ <<EOF
  "days %3E%3D 191",["gatheringFrequency",$gfEE],["mobilityFrequency",[0,80,20]],
  "days %3E%3D 200",["gatheringFrequency",$gf1E],["mobilityFrequency",[0,80,8]],
  "days %3E%3D $rd3",["gatheringFrequency",${gf[0]},2],["mobilityFrequency",[0,80,8],2],
EOF
fi
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
jb=(`cat ../$base/jobID_$m`)
for ((x=0;x<nn;x++)); do
nw=0
sleepTime=60
while [ $nw -eq 0 ]; do
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":1,
"loadState":"${jb[x]}_1",
"scenario":[
  "days %3E%3D 166",["vaccinePerformRate",4,61],["infectionProberbility",80,30],
`cat /tmp/e$$`
  "days %3E%3D 217",["gatheringFrequency",$gfO],["mobilityFrequency",[0,80,20],14],
  "days %3E%3D 235",["gatheringFrequency",${gf[2]}],
  "days %3E%3D 251",["gatheringFrequency",$gfP],
  "days %3E%3D 263",["gatheringFrequency",${gf[3]}],
  "days %3E%3D 264",["gatheringFrequency",$gfX,55]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
EOF
nw=`wc -w < /tmp/s$$`
if [ $nw -gt 1 ]; then cat /tmp/s$$; exit;
elif [ $nw -eq 0 ]; then
  echo "$m $t $x -- failed `date +%H:%M:%S`."
  sleep $sleepTime
  sleepTime=10
fi
done
echo `cat /tmp/s$$` >> jobID_$m
echo $m $x `cat /tmp/s$$`
done
done
rm /tmp/s$$ /tmp/e$$
LANG=C date
