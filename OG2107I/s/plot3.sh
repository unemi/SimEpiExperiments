#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
sd=`echo $dirName | awk -F_ '{print $3}'`
popN=10
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%'\''d,000\n",'$pop'/10}'`
spd=12 # steps per day
tl=350
#
for b in 00 10 20 30; do
  pushd ../${mk}_${b}_$sd > /dev/null
  awk '$1>=223{print}' gatFreq.csv > gatFreqSub.csv
  for x in IN TP; do awk '$1>=223{print}' $x.csv > ${x}Sub.csv; done
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
sdx=`date -j -v+${sd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
#
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/OH_10"
#
makePlot () {
echo plot ${mk}_${sd}_$1$2.svg
gnuplot > $dst/${mk}_${sd}_$1$2.svg <<EOF
if ("$1" eq "IN") {
 set terminal svg size 680 300; set key left; set ylabel "infected (%)"
 set yrange [0:1.6]; set y2range [:100]
 set y2label "1st dose vaccinated (%)\ngatherings frequency (‰)" }
else {
 set terminal svg size 720 300; set key left; set ylabel "weekly test positive (%)"
 set yrange [0:0.08]; set y2range [:($2 < 100)?10:1.2]
 set y2label "gatherings frequency (%)" }
set style data lines
set xrange [$2:$tl]
set xtics ($xmarks)
set ytics nomirror
set y2tics
if ($2 < 22) { set label "emergency declaration" at 22,graph .32 }
if ($2 < 117) { set label "stricter measures" at 117,graph .32 }
set label "Election" at 191,graph .46
set label "Olympics" at 217,graph .36
set label "Obon" at 240.5,graph .46
set label "Paralympics" at 251,graph .36
set object rect from 22,graph 0 to 95,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from 117,graph 0 to 131,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
set object rect from 131,graph 0 to 186,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from 186,graph 0 to 208,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
set object rect from 208,graph 0 to $tl,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from 191,graph .3 to 200,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 217,graph .3 to 235,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 240.5,graph .3 to 243.5,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 251,graph .3 to 263,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
if ($2 < 150) {
 set label "Population size = ${popx}" at graph .5,.92 center
 set label "Stronger measure from ${sdx}" at graph .5,.85 center
} else {
 set label "Population size = ${popx}" at graph .95,.92 right
 set label "Stronger measure from ${sdx}" at graph .95,.85 right
}
array col[4] = [ "#990000", "#707000", "#008800", "#0000cc" ]
array vcol[4] = [ "#ffaaaa", "#ddddaa", "#aaffaa", "#aaaaff" ]
array dirs[4]
array bsx[4]
do for [i=1:4] {
 dirs[i] = sprintf("../${mk}_%02d_${sd}/",(i-1)*10)
 bsx[i] = sprintf("%d%%",(i-1)*10)
}
if ("$1" eq "IN") {
 plot for [i=1:3] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:4 notitle dt 2 lc rgb col[i],\
 dirs[4]."$1.csv" using 1:2 title bsx[4] lc rgb col[4] lw 2,\
 dirs[4]."$1.csv" using 1:3 notitle dt 2 lc rgb col[4],\
 dirs[4]."$1.csv" using 1:4 notitle dt 2 lc rgb col[4],\
 'VC.csv' using 1:2 axes x1y2 notitle lc rgb "#606060",\
 for [i=1:3] dirs[i]."gatFreqSub.csv" using 1:(\$2 * 10) axes x1y2 notitle lc rgb col[i],\
 dirs[4]."gatFreq.csv" using 1:(\$2 * 10) axes x1y2 notitle lc rgb col[4] }
else {
 plot for [i=1:3] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=1:3] dirs[i]."$1Sub.csv" using 1:4 notitle dt 2 lc rgb col[i],\
 dirs[4]."$1.csv" using 1:2 title bsx[4] lc rgb col[4] lw 2,\
 dirs[4]."$1.csv" using 1:3 notitle dt 2 lc rgb col[4],\
 dirs[4]."$1.csv" using 1:4 notitle dt 2 lc rgb col[4],\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - 22):(\$2 / 139600.0) title "Tokyo" lc rgb "#44cc44" lw 2,\
 for [i=1:3] dirs[i]."gatFreqSub.csv" using 1:2 axes x1y2 notitle lc rgb col[i],\
 dirs[4]."gatFreq.csv" using 1:2 axes x1y2 notitle lc rgb col[4] }
EOF
}
#
makePlot IN 1
makePlot TP 1
makePlot IN 151
makePlot TP 151
#
open $dst
