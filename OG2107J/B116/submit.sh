#! /bin/bash
base=B046
# dd1=47;aa1=0.6;rr1=20;rrx1=33
# dd2=67;aa2=0.78;rr2=28
# dd3=95;aa3=0.88;rr3=2
# dd4=97;aa4=1.02;rr4=21
#
# dd1=47;aa1=0.6;rr1=20;rrx1=38
# dd2=67;aa2=0.76;rr2=28
# dd3=95;aa3=0.87;rr3=2
# dd4=97;aa4=1.02;rr4=21
dd1=47;aa1=0.6;rr1=20;rrx1=36
dd2=67;aa2=0.77;rr2=28
dd3=95;aa3=0.87;rr3=2
dd4=97;aa4=1.04;rr4=21
tl=116
# tl=80
rm -f gatFreq.info
#
pf=".intlab.soka.ac.jp"
for m in simepiM0{0..7} simepi2 simepi; do
rm -f jobID_$m
case $m in
  simepi) nn=11; ;;
  simepi2) nn=5; ;;
  *) nn=6; ;;
esac
jb=`cat ../$base/jobID_$m`
for ((x=0;x<nn;x++)); do
sed '/^#/d' > /tmp/d$$_${m}_$x <<EOF
{"stopAt":$tl,"n":1,
"loadState":"${jb}_$((x+1))",
"scenario":[
# relaxing
  "days %3E%3D $dd1",["gatheringFrequency",$aa1,$rr1],["gatheringSize",[10,40,20],$rrx1],
  ["mobilityFrequency",[0,80,8],$rrx1],
  "days %3E%3D $dd2",["gatheringFrequency",$aa2,$rr2],
# Vaccination starts from Medical workers.
  "days %3E%3D 83",["vaccinePerformRate",0.82,48],
# Lifting emergency delaration in March 21.
  "days %3E%3D $dd3",["gatheringFrequency",$aa3,$rr3],
  "days %3E%3D $dd4",["gatheringFrequency",$aa4,$rr4],
# Alpha variant
  "days %3E%3D 110",["infectionProberbility",70,30]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative","saveState"]}
EOF
if [ ! -f gatFreq.info ]; then
  if [ ! -f ../$base/gatFreq.info ]; then
    echo "../$base/gatFreq.info does not exist."; exit; fi
  cp ../$base/gatFreq.info .
  awk '/days %3E/{split($3,a,"\"");d=a[1]}\
  /gatheringFrequency/{n=split($0,a,",");
  for(i=1;i<=n;i++)if(a[i]=="[\"gatheringFrequency\""){\
    gf=a[i+1];\
    if(substr(gf,length(gf),1)=="]"){gf=substr(gf,1,length(gf)-1);gd=0}\
    else gd=substr(a[i+2],1,length(a[i+2])-1);\
    printf "%s %s %s\n",d,gf,gd;break}}' /tmp/d$$_${m}_0 >> gatFreq.info
  awk 'BEGIN{gf=0;dd=0;print "0 0"}\
    {d=$3;if(d==0)d=.1;if(dd<$1)printf "%g %g\n",$1,gf;\
      gf=$2;dd=$1+d;printf "%g %g\n",dd,gf}\
    END{if(dd<'$tl')printf "%d %g\n",'$tl',gf}' gatFreq.info > gatFreq.csv
fi
done
../../submit.sh $m$pf /tmp/d$$_${m} > jobID_$m &
done
../../submitCheck.sh /tmp/d$$
