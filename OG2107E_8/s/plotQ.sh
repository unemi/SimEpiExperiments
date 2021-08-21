#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
bias=`echo $dirName | awk -F_ '{print $2}'`
rd2=186 # `echo $dirName | awk -F_ '{printf "%d\n",(NF>1)?$3:166}'`
rd3=208;ed3=0 # default lisfting date of stricter measures, July 12
ed3=250
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
spd=12 # steps per day
ed=22 # January 7
rd=95 # March 21
md=117 # April 12
ed2=131 # April 26
tl=411
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
makeDataFile QR indexes '$7+$8' $spd 6
cd ..
done
#
echo '"day"' > z.csv
for ((x=1;x<=tl;x++)); do echo $x >> z.csv; done
lam z.csv MyResult_??/QR.csv > QR.csv
rm z.csv
#
if [ ! -z "$1" ]; then exit; fi
#
nf=`awk 'NR==2{print NF}' QR.csv`
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
dst="." # "/Users/unemi/Program/SimEpidemic/Documents/Figures/OE_8"
#
makePlot () {
echo plot $1$2.svg
gnuplot > $dst/${dirName}_$1$2.svg <<EOF
set terminal svg size 680 300; set key right; set ylabel "infected (%)"
set yrange [0:.13]; set y2label "gatherings frequency (%)"; set y2range [0:10]
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
if ($2 < 150) {
set label "Using the best 8 outof 128 traials\nfrom Dec 22 to May 15." at graph .5,.84 center
} else { set label "Vaccination for $prx of population per day." at graph .5,.84 center }
plot '$1.csv' using 1:2 title "average" lc rgb "#000088",\
 '' using 1:3 title "μ ± σ" dt 2 lc rgb "#000088",\
 '' using 1:4 notitle dt 2 lc rgb "#000088",\
 'gatFreq.csv' using 1:2 axes x1y2 title "gat.freq." lc rgb "#888844"
EOF
}
#
makePlot QR 1
#
open $dst
