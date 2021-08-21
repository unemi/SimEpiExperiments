#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
prx=`echo $dirName | awk -F_ '{printf "%.1f%%\n",$3/10}'`
rd2=186 # `echo $dirName | awk -F_ '{printf "%d\n",(NF>1)?$3:166}'`
rd3=208;ed3=0 # default lisfting date of stricter measures, July 12
ed3=258
popN=10
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%'\''d,000\n",'$pop'/10}'`
spd=12 # steps per day
ed=22 # January 7
rd=95 # March 21
md=117 # April 12
ed2=131 # April 26
tl=0
for f in MyResult_??/daily_*.csv; do
 x=`awk -F, 'END{print $1}' $f`
 if [ $tl -lt $x ]; then tl=$x; fi
done
#
makeDataFile () {
echo $d | awk -F_ '{printf "\t\"%d%%\"\t\"U%s\"\t\"L%s\"\n",$2*20,$2,$2}' > $1.csv
awk -F, '$1>0{x+='$3';n++;if($1%'$4'==0)\
{z=x/n;k=$1/'$4';v[k]+=z;v2[k]+=z*z;nv[$1/'$4']++;x=0;n=0}}\
 END{for(i=1;nv[i]>0;i++){e=v[i]/nv[i]/'$pop'.;\
 vv=(v2[i]-v[i]*v[i]/nv[i])/nv[i];if(vv<0)s=0;else s=sqrt(vv)/'$pop'.;\
 printf "\t%.'$5'f\t%.'$5'f\t%.'$5'f\n",e,e+s,e-s}}' $2_*.csv >> $1.csv
}
for d in MyResult_??; do
cd $d
for f in daily_*.csv; do
awk -F, 'NR==1{i=0;for(j=2;j<=NF;j++){s[j]=0;for(k=0;k<7;k++)q[j*7+k]=0}print}\
$1>0{if(n<7)n++;for(j=2;j<=NF;j++){k=j*7+i;s[j]+=$j-q[k];q[k]=$j}i=(i+1)%7;\
if(n>=4){printf "%s",$1-3;for(j=2;j<=NF;j++){printf ",%.4f",s[j]/n}print ""}}\
END{for(a=1;a<=3;a++){printf "%d",$1-3+a;n--;\
for(j=2;j<=NF;j++){s[j]-=q[j*7+i];printf ",%.4f",s[j]/n}print ""}}'\
 $f > weekly_`echo $f | awk -F_ '{print $2}'`
done
makeDataFile IN indexes '$2+$3' $spd 6
makeDataFile TP weekly '$2' 1 8
makeDataFile VC indexes '$6' $spd 6
cd ..
done
#
echo '"day"' > z.csv
for ((x=1;x<=tl;x++)); do echo $x >> z.csv; done
lam z.csv MyResult_??/IN.csv > IN.csv
lam z.csv MyResult_??/TP.csv > TP.csv
lam z.csv MyResult_??/VC.csv > VC.csv
rm z.csv
#
if [ ! -z "$1" ]; then exit; fi
#
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
echo plot $1$2$3.svg
gnuplot > $dst/${dirName}_$1$2$3.svg <<EOF
if ("$1" eq "IN") {
 set terminal svg size 680 300; set ylabel "infected (%)"
 set y2label "gatherings frequency (%)"; set y2range [0:10]  }
else {
 set terminal svg size 720 300; set ylabel "weekly test positive (%)"
 set y2label "1st dose vaccinated (%)\ngatherings frequency (‰)"
 set y2range [0:100] }
if ("$2" eq "1") {
  if ("$1" eq "IN") { set key right }
  else { set key right bottom }
} else { set key left }
set yrange [0:$3]
set style data lines
set xrange [$2:$tl]
set xtics ($xmarks)
set ytics nomirror
set y2tics
if ($2 < $ed) { set label "emergency declaration" at $ed,graph .32 }
if ($2 < $md) { set label "stricter measures" at $md,graph .32 }
set label "election" at 191,graph .46
set label "Olympic" at 217,graph .36
set label "Obon" at 240.5,graph .46
set label "Paralympic" at 251,graph .36
set object rect from $ed,graph 0 to $rd,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $md,graph 0 to $ed2,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
set object rect from $ed2,graph 0 to $rd2,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $rd2,graph 0 to $rd3,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
if ("$ed3" > 0) {
set object rect from $rd3,graph 0 to $ed3,graph .3 back fc rgb "red" fs solid 0.1 lw 0
}
set object rect from 191,graph .3 to 200,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 217,graph .3 to 235,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 240.5,graph .3 to 243.5,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 251,graph .3 to 263,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set label "Population size = ${popx}" at graph .5,.92 center
if ("$1" eq "IN") { plot '$1.csv' using 1:2 title "average" lc rgb "#000088",\
 '' using 1:3 title "μ ± σ" dt 2 lc rgb "#000088",\
 '' using 1:4 notitle dt 2 lc rgb "#000088",\
 'gatFreq.csv' using 1:2 axes x1y2 title "gat.freq." lc rgb "#888844" }
else { plot '$1.csv' using 1:2 title "average" lc rgb "#000088",\
 '' using 1:3 title "μ ± σ" dt 2 lc rgb "#000088",\
 '' using 1:4 notitle dt 2 lc rgb "#000088",\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2,\
 'VC.csv' using 1:2 axes x1y2 title "vaccinated" lc rgb "#cc44cc",\
 'gatFreq.csv' using 1:(\$2 * 10) axes x1y2 title "gat.freq." lc rgb "#888844"
  }
EOF
}
#
dst=.
makePlot IN 1 .5
makePlot TP 1 .02
makePlot IN 151 .5
makePlot TP 151 .02
makePlot IN 1 ""
makePlot TP 1 ""
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/OH_10"
makePlot IN 151 ""
makePlot TP 151 ""
#
open $dst