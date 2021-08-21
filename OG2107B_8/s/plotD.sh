#! /bin/bash
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{printf "%s_%s",$1,$2}'`
gfClmn=`echo $dirName | awk -F_ '{print ($2==0)?2:3}'`
spd=12 # steps per day
ed=22 # January 7, emergency declaration
rd=95 # March 21, lifting
md=117 # April 12, stricter measures
ed2=131 # April 26
rd2=186 # June 20
elS=191 # June 25 Tokyo election start
elV=200 # July 4 Election day
ogO=217 # July 21, Olympic games
ogC=235 # August 8
pgO=251 # August 24, Parlympic games
pgC=263 # September 5
dfs=(MyResult_*/daily_*.csv)
if [ ${#dfs[@]} -le 1 ]; then echo "No data files"; exit; fi 
tl=`awk -F, 'END{print $1}' $dfs`
#
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/OB_$popN"
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
gf[$nj]=`echo $jobDir | awk -F_ '{print $3}'`
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
set terminal svg size 820 300
if ("$1" eq "IN") { set ylabel "infected (%)" }
else { set ylabel "weekly test positive (%)" }
set style data lines
set xrange [1:$tl]
if ("$1" eq "IN") { set yrange [0:.3]; set y2label "gatherings frequency (%)" }
else { set yrange [0:.014]; set y2label "1st dose vaccinated (%)" }
set xtics (${xmarks[@]})
set ytics nomirror
set y2tics
set key outside right
set label "emergency declaration" at $ed,graph .56
set label "stricter measures" at $md,graph .63
set label "emergency declaration" at $ed2,graph .56
set label "Election" at $elS,graph .63
set label "Olympic" at $ogO,graph .56
set label "Paralympic" at $pgO,graph .56
set object rect from $ed,graph 0 to $rd,graph .5 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $md,graph 0 to $ed2,graph .5 back fc rgb "yellow" fs solid 0.5 lw 0
set object rect from $ed2,graph 0 to $rd2,graph .5 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $elS,graph 0 to $elV,graph .5 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from $ogO,graph 0 to $ogC,graph .5 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from $pgO,graph 0 to $pgC,graph .5 back fc rgb "blue" fs solid 0.1 lw 0
set label "Population size = ${popx}" at graph .5,.85 center
array gfx[$nj] = [ ${gfx[@]} ]
array dfn[$nj] = [ ${dfn[@]} ]
array col[$nj]
do for [i=1:$nj] { col[i] = hsv2rgb((i-1.)/$nj,1.,.67) }
if ("$1" ne "TP") { plot\
 for [i=$nj:1:-1] dfn[i] using 1:2 title gfx[i] lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:4 notitle dt 2 lc rgb col[i],\
 '../gatFreq.csv' using 1:$gfClmn axes x1y2 title "gat.freq." lc rgb "#880066" }
else { plot\
 for [i=$nj:1:-1] dfn[i] using 1:2 title gfx[i] lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:3 notitle dt 2 lc rgb col[i],\
 for [i=$nj:1:-1] dfn[i] using 1:4 notitle dt 2 lc rgb col[i],\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2,\
 'VC.csv' using 1:2 axes x1y2 title "vaccinated" lc rgb "#880066" }
EOF
}
#
makePlot IN
makePlot TP
#
rm ../P_{IN,TP}_[0-9][0-9].csv
open $dst
