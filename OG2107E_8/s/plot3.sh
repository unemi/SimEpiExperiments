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
LANG=C
tspan=$(((tl-1)/10))
declare -a arr
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
#
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/OE_8"
#
makePlot () {
echo plot $1$2.svg
gnuplot > $dst/${mk}_${bias}_$1$2.svg <<EOF
if ("$1" eq "IN") {
 set terminal svg size 680 300; set key left; set ylabel "infected (%)"
 set yrange [0:.3]; set y2range [:10]; set y2label "gatherings frequency (%)" }
else {
 set terminal svg size 720 300; set key left; set ylabel "weekly test positive (%)"
 set yrange [0:.014]; set y2range [:100]
 set y2label "1st dose vaccinated (%)\ngatherings frequency (‰)" }
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
array col[4] = [ "#990000", "#707000", "#008800", "#0000cc" ]
array vcol[4] = [ "#ffaaaa", "#ddddaa", "#aaffaa", "#aaaaff" ]
array dirs[4]
array prx[4]
do for [i=1:4] {
 dirs[i] = sprintf("../${mk}_${bias}_%02d/",(i-1)*10)
 prx[i] = sprintf("%d%%",(11-i)*10)
}
if ($2 < 150) {
set label "Using the best 8 outof 128 traials\nfrom Dec 22 to May 15." at graph .5,.84 center
}
if ("$1" eq "IN") {
 plot for [i=1:4] dirs[i]."$1.csv" using 1:2 title prx[i] lc rgb col[i] lw 2,\
 for [i=1:4] dirs[i]."$1.csv" using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=1:4] dirs[i]."$1.csv" using 1:4 notitle dt 2 lc rgb col[i],\
 'gatFreq.csv' using 1:2 axes x1y2 title "gat.freq." lc rgb "#606060" }
else {
 plot for [i=1:4] dirs[i]."$1.csv" using 1:2 title prx[i] lc rgb col[i] lw 2,\
 for [i=1:4] dirs[i]."$1.csv" using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=1:4] dirs[i]."$1.csv" using 1:4 notitle dt 2 lc rgb col[i],\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#44cc44" lw 2,\
 for [i=1:4] dirs[i]."VC.csv" using 1:2 axes x1y2 notitle lc rgb vcol[i],\
 'gatFreq.csv' using 1:(\$2 * 10) axes x1y2 title "gat.freq." lc rgb "#606060"
  }
EOF
}
#
# makePlot IN 1
# makePlot TP 1
makePlot IN 151
makePlot TP 151
#
open $dst
