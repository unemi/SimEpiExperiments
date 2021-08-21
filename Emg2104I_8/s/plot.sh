#! /bin/bash
nd=`pwd | awk -F/ '{print ($NF~/^V_[0-9]_[0-9][0-9]_[0-9][0-9]/)?$NF:1}'`
if [ $nd = 1 ]; then echo "This script must run from V_9_99_99."; exit; fi
mm=`echo $nd | awk -F_ '{print $1}'`
vp=`echo $nd | awk -F_ '{print $2}'`
pr=`echo $nd | awk -F_ '{printf "%d\n",$3}'`
cg=`echo $nd | awk -F_ '{print $4}'`
jd=`pwd | awk -F/ '{print $(NF-1)}'`
jn=`echo $jd | awk -F_ '{print substr($(NF-1),length($(NF-1)),1)}'`
popN=`echo $jd | awk -F_ '{printf "%d\n",$NF}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
spd=12 # steps per day
ed=22 # January 7
rd=95 # March 21
md=117 # April 12
ed2=130 # April 25
vd=136 # vaccination start day (May 1)
rd2=147 # May 12
tl=258 # August 31
vpName=`echo $vp | awk -F, '{print ($1==0)?"random":($1==1)?"active individual":\
 ($1==4)?"dense area":($1==9)?"contacts":"unknown"}'`
#
makeDataFile () {
echo $d | awk -F_ '{printf "\t\"%d%%\"\t\"U%s\"\t\"L%s\"\n",$2*20,$2,$2}' > $1.csv
awk -F, '$1>0{x+='$3';n++;if($1%'$4'==0)\
{z=x/n;k=$1/'$4';v[k]+=z;v2[k]+=z*z;nv[$1/'$4']++;x=0;n=0}}\
 END{for(i=1;nv[i]>0;i++){e=v[i]/nv[i]/'$pop'.;s=sqrt((v2[i]-v[i]*v[i]/nv[i])/nv[i])/'$pop'.;\
 printf "\t%.'$5'f\t%.'$5'f\t%.'$5'f\n",e,e+s,e-s}}' $2_*.csv >> $1.csv
}
for d in MyResult_??; do
cd $d
makeDataFile IN indexes '$2+$3' $spd 6
makeDataFile TP daily '$2' 1 8
cd ..
done
#
echo '"day"' > z.csv
for ((x=cmd;x<=tl;x++)); do echo $x >> z.csv; done
lam z.csv MyResult_??/IN.csv > IN.csv
lam z.csv MyResult_??/TP.csv > TP.csv
rm z.csv
#
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/${jn}_$popN"
if [ ! -d $dst ]; then mkdir -p $dst; fi
nf=`awk 'NR==2{print NF}' IN.csv`
#
LANG=C
tspan=$(((tl-1)/10))
declare -a arr
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
#
makePlot () {
echo plot ${mm}_$1_${vp}_${pr}_${cg}.svg
gnuplot > $dst/${mm}_$1_${vp}_${pr}_${cg}.svg <<EOF
set terminal svg size 640 300
set style data lines
if ("$1" eq "IN") { set ylabel "infected (%)" }
else { set ylabel "test positive (%)" }
set xrange [1:$tl]
if ("$1" eq "IN") { set yrange [0:.4] }
else { set yrange [0:.015] }
set xtics ($xmarks)
set label "→ emergency declaration" at $ed,graph .7
set label "→ lift declaration" at $rd,graph .63
set label "→ stricter measures" at $md,graph .2
set label "→ emergency declaration" at $ed2,graph .7
set label "→ lift declaration" at $rd2,graph .63
set arrow from $ed,graph 0 to $ed,graph .75 nohead lc rgb "#884400"
set arrow from $rd,graph 0 to $rd,graph .68 nohead lc rgb "#004488"
set arrow from $md,graph 0 to $md,graph .5 nohead lc rgb "#888800"
set arrow from $ed2,graph 0 to $ed2,graph .75 nohead lc rgb "#884400"
set arrow from $rd2,graph 0 to $rd2,graph .68 nohead lc rgb "#004488"
if ($pr > 0 || $cg > 0) {
set size 1,0.95
if ($pr > 0) {
set label "Population size = ${popx}; Vaccination perform rate = 0.${pr}%,\
 priotity = $vpName; Cluster granularity = ${cg}%." at screen .5,.95 center
set label "→ vaccination" at $vd,graph .13
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgb "#880088" }
else { set label "Population size = ${popx}; Without vaccination,\
 Cluster granularity = ${cg}%." at screen .5,.95 center }
set key right title "cluster rate" right
plot for [i=2:${nf}:3] '$1.csv' using 1:i title columnhead\
 lc rgb hsv2rgb((i-2.)/($nf-1),1.,.667)
}
else { set key right
set label "Population size = ${popx}\nWithout vaccination" at screen .5,.85 center
plot '$1.csv' using 1:2 title "average" lc rgb "#880000",\
 '' using 1:3 title "μ ± σ" dt 2 lc rgb "#880000",\
 '' using 1:4 notitle dt 2 lc rgb "#880000"}
EOF
}
#
makePlot IN
makePlot TP
#
open $dst
