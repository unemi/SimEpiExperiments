#! /bin/bash
# evaluation by simulation
# arguments : [01] gf1-6
if [ $# -lt 7 ]; then echo "Seven arguments are required."; exit; fi
echo "`date +%H:%M:%S` start $$ $1 $2 $3 $4 $5 $6 $7"
ed=22
if [ ! -f Tokyo.csv ]; then
  awk '$1>316+'$ed'{print $2}'\
  /Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv\
  > Tokyo.csv
fi
tl=`awk 'END{print NR}' Tokyo.csv`
nyd=`echo $ed | awk '{print $1 - 11}'`
wd=`expr $ed - 3`
dd=`expr $ed + 1`
dd2=81
dp=`expr $dd2 - $dd`
dp2=`expr $tl - $dd2`
pf=".intlab.soka.ac.jp"
if [ ! -d jobIDs ]; then mkdir jobIDs; fi
if [ ! -d evaluated ]; then mkdir evaluated; fi
mList="simepiM0{0..7} simepi2 simepi"
for m in $mList; do
if [ $1 -eq 0 ]; then
	case $m in
	  simepi) nn=3; ;;
	  simepi2) nn=1; ;;
	  *) nn=2; ;;
	esac
else nn=2
fi
popn=`pwd | awk -F/ '{d=$(NF-1);print substr(d,length(d),1)}`
s=`echo $popn | awk '{printf "%d0000,\"worldSize\":%d,\"mesh\":%d\n", $1*$1, $1*700, $1*25}'`
curl http://$m$pf/submitJob -s -d @- > /tmp/s$$ <<EOF
job={"stopAt":$tl,"n":$nn,
"params":{"populationSize":$s,
  "activenessMode":20,
  "avoidance":70,
  "fatalityBias":20,
  "friction":40,
  "gatheringBias":80,
  "gatheringDuration":[3,12,6],
  "gatheringFrequency":$2,
  "gatheringParticipation":[0,100,20],
  "gatheringSize":[10,40,20],
  "homeMode":2,
  "incubationBias":20,
  "incubation":[2,20,7],
  "infectionProberbility":80,
  "initialInfectedRate":0.02,
  "mobilityBias":80,
  "quarantineAsymptomatic":3,
  "quarantineSymptomatic":70,
  "subjectAsymptomatic":0,
  "subjectSymptomatic":50,
  "vaccineEffectPeriod":100,
  "vaccinePerformRate":0},
"scenario":["days %3E%3D $nyd",
  ["gatheringFrequency",$3],
  ["mobilityFrequency",[0,80,70]],
  ["backHomeRate",20],
  "days %3E%3D $wd",
  ["gatheringFrequency",$4],
  ["mobilityFrequency",[0,70,60]],
  ["backHomeRate",75],
  "days %3E%3D $ed",
  ["gatheringFrequency",$5],
  ["mobilityFrequency",[0,60,50]],
  "days %3E%3D $dd",
  ["gatheringFrequency",$6,$dp],
  ["mobilityFrequency",[0,80,70],$dp],
  "days %3E%3D $dd2",
  ["gatheringFrequency",$7,$dp2]],
"out":["dailyTestPositive"]}
EOF
if [ `wc -w < /tmp/s$$` -gt 1 ]; then cat /tmp/s$$; exit; fi
echo `cat /tmp/s$$` >> jobIDs/${m}_$$
echo $x $m `cat /tmp/s$$`
done
rm /tmp/s$$
#
sleep 660
declare -a mArray
mArray=($mList)
while [ ${#mArray[@]} -gt 0 ] ; do
 sleep 60
 for idx in ${!mArray[@]}; do
   m=${mArray[$idx]}
   j=`cat jobIDs/${m}_$$`
   r=`curl -s http://$m$pf/getJobStatus?job=$j`
   if [ `echo $r | grep -q ':\[\],.*:0\}'; echo $?` = 0 ]; then
     unset mArray[$idx]
   fi
 ((idx++))
 done
done
#
pop=$((popn*popn))
for m in $mList; do
  j=`cat jobIDs/${m}_$$`
  r=`curl -s http://$m$pf/getJobResult?job=$j\&save=R${m}_$$`
  if [ "$r" != "OK" ]; then echo "$r"; exit; fi
  if [ -f R${m}_$$.zip ]; then
    unzip -q R${m}_$$; rm -f R${m}_$$.zip
  fi
done
nf=`echo R*_$$/daily_*.csv | awk '{print NF}'`
cat R*_$$/daily_*.csv | awk '{a[$1]+=$2;if(n<$1)n=$1}\
 END{for(i=1;i<=n;i++)printf "%d\t%.4f\n",i,a[i]/'$nf'}' > evaluated/A_$$.csv
cat Tokyo.csv evaluated/A_$$.csv | awk '{if(NF==1)tk[NR]=$1;else{a[$1]+=$2;if(n<$1)n=$1}}\
END{dsum=0;for(i='$ed';i<=n;i++){d=a[i]/'$pop'-tk[i]/1396;dsum+=d*d}\
printf "'$2'\t'$3'\t'$4'\t'$5'\t'$6'\t'$7'\t%.4f\n",dsum/(n-'$ed'+1)}'\
 > evaluated/E_$$.csv
rm -rf R*_$$ jobIDs/*_$$
echo "`date +%H:%M:%S` end $$ `awk '{print $NF}' evaluated/E_$$.csv`"
