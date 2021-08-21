#! /bin/bash
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
spd=12 # steps per day
ed=22 # January 7, emergency declaration
rd=95 # March 21, lifting
md=117 # April 12, stricter measures
ed2=131 # April 26
rd2=186 # June 20
ogO=217 # July 21, Olympic games
ogC=235 # August 8
tl=258 # August 31
#
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/K_$popN"
if [ ! -d $dst ]; then mkdir -p $dst; fi
nf=`awk 'NR==2{print NF}' IN.csv`
#
LANG=C
tspan=$(((tl-1)/10))
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+1))
xmarks[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
#
nj=0
for jobDir in ../${mk}_??; do
nj=$((nj+1))
gf[$nj]=`echo $jobDir | awk -F_ '{print $2}'`
gfx[$nj]=`echo ${gf[$nj]} | awk '{printf "\"x%.1f\",",$1/10}'`
for t in IN TP; do
 if [ $nj -eq 1 ]; then cp $jobDir/$t.csv ../P_${t}_${gf[$nj]}.csv
 else awk '$1>165{print}' $jobDir/$t.csv > ../P_${t}_${gf[$nj]}.csv; fi
done
done
LANG=ja_JP.UTF-8
#
makePlot () {
echo plot ${mk}_$1.svg
for ((i=1;i<=nj;i++))
  do dfn[$i]=`echo ${gf[$i]} | awk '{printf "\"../P_'$1'_%s.csv\",",$1}'`; done
gnuplot > $dst/${mk}_$1.svg <<EOF
set terminal svg size 640 300
set style data lines
if ("$1" eq "IN") { set ylabel "infected (%)" }
else { set ylabel "test positive (%)" }
set xrange [1:$tl]
if ("$1" eq "IN") { set yrange [0:.3] }
else { set yrange [0:.014] }
set xtics (${xmarks[@]})
set label "emergency declaration" at $ed,graph .56
set label "stricter measures" at $md,graph .63
set label "emergency declaration" at $ed2,graph .56
set label "Tokyo 2020" at 217,graph .56
set object rect from $ed,graph 0 to $rd,graph .5 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $md,graph 0 to $ed2,graph .5 back fc rgb "yellow" fs solid 0.5 lw 0
set object rect from $ed2,graph 0 to $rd2,graph .5 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $ogO,graph 0 to $ogC,graph .5 back fc rgb "blue" fs solid 0.1 lw 0
set key right
set label "Population size = ${popx}" at screen .5,.85 center
array gfx[$nj] = [ ${gfx[@]} ]
array dfn[$nj] = [ ${dfn[@]} ]
array col[$nj]
do for [i=1:$nj] { col[i] = hsv2rgb((i-1.)/$nj,1.,.67) }
if ("$1" ne "TP") { plot\
 for [i=$nj:1:-1] dfn[i] using 1:2 title gfx[i] lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:4 notitle dt 2 lc rgb col[i] }
else { plot\
 for [i=$nj:1:-1] dfn[i] using 1:2 title gfx[i] lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:4 notitle dt 2 lc rgb col[i],\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2 }
EOF
}
#
makePlot IN
makePlot TP
#
open $dst
