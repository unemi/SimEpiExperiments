#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
spd=12 # steps per day
tl=350
#
for ((b=60;b<120;b+=20)); do
  pushd ../${mk}_$b > /dev/null
  awk '$1>=208 && $1<=250{print}' gatFreq.csv > gatFreqSub.csv
  for x in IN TP; do awk '$1>=208{print}' $x.csv > ${x}Sub.csv; done
  popd > /dev/null
done
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
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/OG_8"
#
makePlot () {
echo plot $1$2.svg
gnuplot > $dst/${mk}_$1$2.svg <<EOF
if ("$1" eq "IN") {
 set terminal svg size 680 300; set key left; set ylabel "infected (%)"
 set yrange [0:.35]; set y2range [:10]; set y2label "gatherings frequency (%)" }
else {
 set terminal svg size 720 300; set key left; set ylabel "weekly test positive (%)"
 set yrange [0:.016]; set y2range [:100]
 set y2label "1st dose vaccinated (%)\ngatherings frequency (‰)" }
set style data lines
set xrange [$2:$tl]
set xtics ($xmarks)
set ytics nomirror
set y2tics
if ($2 < 22) { set label "emergency declaration" at 22,graph .32 }
if ($2 < 117) { set label "stricter measures" at 117,graph .32 }
set label "election" at 191,graph .46
set label "Olympic" at 217,graph .36
set label "Obon" at 240.5,graph .46
set label "Paralympic" at 251,graph .36
set object rect from 22,graph 0 to 95,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from 117,graph 0 to 131,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
set object rect from 131,graph 0 to 186,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from 186,graph 0 to 208,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
set object rect from 208,graph 0 to 250,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from 191,graph .3 to 200,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 217,graph .3 to 235,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 240.5,graph .3 to 243.5,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 251,graph .3 to 263,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set label "Population size = ${popx}" at graph .5,.92 center
array col[4] = [ "#990000", "#707000", "#008800", "#0000cc" ]
array vcol[4] = [ "#ffaaaa", "#ddddaa", "#aaffaa", "#aaaaff" ]
array dirs[4]
array bsx[4]
do for [i=1:4] {
 dirs[i] = sprintf("../${mk}_%02d/",(i-1)*20+60)
 bsx[i] = sprintf("%d%%",(i-1)*20+60)
}
if ("$1" eq "IN") {
 plot for [i=1:3] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:4 notitle dt 2 lc rgb col[i],\
 dirs[4]."$1.csv" using 1:2 title bsx[4] lc rgb col[4] lw 2,\
 dirs[4]."$1.csv" using 1:3 notitle dt 2 lc rgb col[4],\
 dirs[4]."$1.csv" using 1:4 notitle dt 2 lc rgb col[4],\
 for [i=1:3] dirs[i]."gatFreqSub.csv" using 1:2 axes x1y2 notitle lc rgb col[i],\
 dirs[4]."gatFreq.csv" using 1:2 axes x1y2 notitle lc rgb col[4] }
else {
 plot for [i=1:3] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:4 notitle dt 2 lc rgb col[i],\
 dirs[4]."$1.csv" using 1:2 title bsx[4] lc rgb col[4] lw 2,\
 dirs[4]."$1.csv" using 1:3 notitle dt 2 lc rgb col[4],\
 dirs[4]."$1.csv" using 1:4 notitle dt 2 lc rgb col[4],\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - 22):(\$2 / 139600.0) title "Tokyo" lc rgb "#44cc44" lw 2,\
 'VC.csv' using 1:2 axes x1y2 notitle lc rgb "#606060",\
 for [i=1:3] dirs[i]."gatFreqSub.csv" using 1:(\$2 * 10) axes x1y2 notitle lc rgb col[i],\
 dirs[4]."gatFreq.csv" using 1:(\$2 * 10) axes x1y2 notitle lc rgb col[4] }
EOF
}
#
makePlot IN 1
makePlot TP 1
makePlot IN 151
makePlot TP 151
#
open $dst
