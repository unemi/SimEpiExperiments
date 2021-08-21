#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
sd=`echo $dirName | awk -F_ '{print $3}'`
popN=10
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%'\''d,000\n",'$pop'/10}'`
spd=12 # steps per day
difD=242
tl=350
#
declare -a prms
nPrms=0
for b in ../${mk}_*_$sd; do
  pushd $b > /dev/null
  if [ -f gatFreq.csv ]
   then awk '$1>='$difD'{print}' gatFreq.csv > gatFreqSub.csv
   n=0
   for x in IN TP SV AP; do if [ -f $x.csv ]
     then awk 'NR>='$difD'{printf "%d %s\n",NR,$0}' $x.csv > ${x}Sub.csv
     n=$((n+1)); fi; done
   if [ -f VC.csv ]; then n=$((n+1)); fi
   if [ $n = 5 ]; then prms[$nPrms]=`echo $b | awk -F_ '{print $2}'`; nPrms=$((nPrms+1)); fi
  fi
  popd > /dev/null
done
if [ $nPrms = 0 ]; then echo "No data found."; exit; fi
echo ${prms[@]}
prmsx=`echo ${prms[@]} | awk '{for(i=1;i<=NF;i++)printf "%d,%s",$i,(i<NF)?" ":"\n"}'`
#
makeXMarks () {
LANG=C
local tspan=$(((tl-$1)/10))
declare -a arr
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+$1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
}
#
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/OJ_10"
if [ ! -d $dst ]; then mkdir $dst; fi
sdx=`LANG=C date -j -v+${sd}d 121601002020 "+%b %e" | sed 's/  / /'`
#
makePlot () {
echo plot ${mk}_${sd}_$1$2.svg
makeXMarks $2
gnuplot > $dst/${mk}_${sd}_$1$2.svg <<EOF
if ("$1" eq "IN") {
 set terminal svg size 680 300; set ylabel "infected (%)"
 set yrange [0:]; set y2range [0:100]
 set y2label "1st dose vaccinated (%)\ngatherings frequency (‰)" }
else { if ("$1" eq "TP") {
 set ylabel "weekly test positive (%)"; set yrange [0:] }
else { if ("$1" eq "SV") {
 set ylabel "severe patients (%)";set yrange [0:] }
else { if ("$1" eq "AP") {
 set ylabel "asymptomatic patients in community (%)";set yrange [0:] }}}
 set terminal svg size 720 300
 set y2label "gatherings frequency (%)"; set y2range [0:($2 < 100)?10:1.4]
}
set key left
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
array prms[$nPrms] = [ $prmsx ]
array col[$nPrms]
array vcol[$nPrms]
array dirs[$nPrms]
array bsx[$nPrms]
do for [i=1:$nPrms] {
 col[i] = hsv2rgb((i-1.)/$nPrms,1.,.5)
 vcol[i] = hsv2rgb((i-1.)/$nPrms,.75,1.)
 dirs[i] = sprintf("../${mk}_%03d_${sd}/",prms[i])
 bsx[i] = sprintf("%d%%",prms[i])
}
if ("$1" eq "IN") {
 plot for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2+\$3) notitle dt 2 lc rgb col[i],\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2-\$3) notitle dt 2 lc rgb col[i],\
 dirs[$nPrms]."$1.csv" using 0:1 title bsx[$nPrms] lc rgb col[$nPrms] lw 2,\
 dirs[$nPrms]."$1.csv" using 0:(\$1+\$2) notitle dt 2 lc rgb col[$nPrms],\
 dirs[$nPrms]."$1.csv" using 0:(\$1-\$2) notitle dt 2 lc rgb col[$nPrms],\
 'VC.csv' using 0:1 axes x1y2 notitle lc rgb "#606060",\
 for [i=1:$((nPrms-1))] \
   dirs[i]."gatFreqSub.csv" using 1:(\$2 * 10) axes x1y2 notitle lc rgb col[i],\
 dirs[$nPrms]."gatFreq.csv" using 1:(\$2 * 10) axes x1y2 notitle lc rgb col[$nPrms] }
else { if ("$1" eq "TP") {
 plot for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2+\$3) notitle dt 2 lc rgb col[i],\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2-\$3) notitle dt 2 lc rgb col[i],\
 dirs[$nPrms]."$1.csv" using 0:1 title bsx[$nPrms] lc rgb col[$nPrms] lw 2,\
 dirs[$nPrms]."$1.csv" using 0:(\$1+\$2) notitle dt 2 lc rgb col[$nPrms],\
 dirs[$nPrms]."$1.csv" using 0:(\$1-\$2) notitle dt 2 lc rgb col[$nPrms],\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - 22):(\$2 / 139600.0) title "Tokyo" lc rgb "#44cc44" lw 2,\
 for [i=1:$((nPrms-1))] dirs[i]."gatFreqSub.csv" using 1:2 axes x1y2 notitle lc rgb col[i],\
 dirs[$nPrms]."gatFreq.csv" using 1:2 axes x1y2 notitle lc rgb col[$nPrms] }
else { if ("$1" eq "SV") {
 plot for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2+\$3) notitle dt 2 lc rgb col[i],\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2-\$3) notitle dt 2 lc rgb col[i],\
 dirs[$nPrms]."$1.csv" using 0:1 title bsx[$nPrms] lc rgb col[$nPrms] lw 2,\
 dirs[$nPrms]."$1.csv" using 0:(\$1+\$2) notitle dt 2 lc rgb col[$nPrms],\
 dirs[$nPrms]."$1.csv" using 0:(\$1-\$2) notitle dt 2 lc rgb col[$nPrms],\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/tky_patients.csv'\
  using 0:(\$4 / 139600.) title "Tokyo" lc rgb "#44cc44" lw 2,\
 for [i=1:$((nPrms-1))] dirs[i]."gatFreqSub.csv" using 1:2 axes x1y2 notitle lc rgb col[i],\
 dirs[$nPrms]."gatFreq.csv" using 1:2 axes x1y2 notitle lc rgb col[$nPrms] }
else {
 plot for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2+\$3) notitle dt 2 lc rgb col[i],\
 for [i=1:$((nPrms-1))] dirs[i]."$1Sub.csv" using 1:(\$2-\$3) notitle dt 2 lc rgb col[i],\
 dirs[$nPrms]."$1.csv" using 0:1 title bsx[$nPrms] lc rgb col[$nPrms] lw 2,\
 dirs[$nPrms]."$1.csv" using 0:(\$1+\$2) notitle dt 2 lc rgb col[$nPrms],\
 dirs[$nPrms]."$1.csv" using 0:(\$1-\$2) notitle dt 2 lc rgb col[$nPrms],\
 for [i=1:$((nPrms-1))] dirs[i]."gatFreqSub.csv" using 1:2 axes x1y2 notitle lc rgb col[i],\
 dirs[$nPrms]."gatFreq.csv" using 1:2 axes x1y2 notitle lc rgb col[$nPrms] }
}}
EOF
}
#
for tp in IN TP SV AP; do for st in 1 151; do makePlot $tp $st; done; done
#
open $dst
