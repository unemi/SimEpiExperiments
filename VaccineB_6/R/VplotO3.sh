#! /bin/bash
#
plot () {
local nm=$1
local yr=""
if [ $# -gt 2 ]; then
  nm=$1_`echo $3 | cut -c2-`
  yr="set yrange [:$3]"
fi
echo plot $nm.svg 
gnuplot > $dst/$nm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00\nGathering frequency = ${gf}%" at screen .5,.85 center
unset key
set style data lines
set ylabel "$2 (%)"
set xrange [:$tl]
$yr
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at 22,graph .1
set label "→ lifting" at $rd,graph .5
set label "→ vaccine" at $vd,graph .6
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .6 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .7 nohead lc rgbcolor "#660099"
plot for [i=2:(${nf}+1)] '$1.csv' using 1:i
EOF
}
plotA () {
local nm=$outfn
local yr=""
if [ $# -gt 1 ]; then
  nm=${outfn}_`echo $2 | cut -c2-`
  yr="set yrange [:$2]"
fi
echo plot $nm.svg
gnuplot > $dst/$nm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00\nGathering frequency = ${gf}%" at screen .5,.85 center
set key right bottom title "perform rate" left
set style data lines
set ylabel "$1 (%)"
set xrange [:$tl]
$yr
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at 22,graph .1
set label "→ lifting" at $rd,graph .5
set label "→ vaccine" at $vd,graph .6
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .6 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .7 nohead lc rgbcolor "#660099"
plot for [i=2:${nf}] '$outfn.csv' using 1:i title columnhead lc rgb hsv2rgb((i-1.)/${nf},1,.8)
EOF
}
#
gf=3  # gathering frequency after lifting the emergency delaration
tl=258
nd=`pwd | awk -F/ '{print substr($NF,4,7)}'`  # ex. 074_106 = Feb28 lift, Apr1 vaccine
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/V_G$nd"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`pwd | awk -F/ '{n=substr($(NF-1),length($(NF-1)),1);printf "%d\n",n*n*100}'`
rd=`echo $nd | awk -F_ '{printf "%d\n",$1}'`
vd=`echo $nd | awk -F_ '{print $2}'`
#
# if [ ! -f  ]; then
#
for d in MyResult_??; do
cd $d
nx=`echo $d | awk -F_ '{printf "%s_%02d_O'$gf'\n",($2<5)?"fair":"worse",2^($2%5)}'`
n=0;s=0
for f in indexes_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi
  nn=`head -2 $f | tail -1 | cut -d, -f1`
  if [ $s -lt $nn ]; then s=$nn; fi
done
touch XX.csv
for f in indexes_*.csv; do
  awk -F, '$1>0{x+=$2+$3;n++;if($1%'$s'==0){printf "\t%.6f\n",x/n/'$pop'.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/'$s';i<$1/'$s';i++) print "\t0"}' >> X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
done
awk '{printf "%.4f%s\n",NR*'$s'/16,$0}' XX.csv > ../in_$nx.csv
rm XX.csv
#
n=0
for f in daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi 
done
touch XX.csv
for f in daily_*.csv; do
  awk -F, '$1>0{printf "\t%.8f\n",$2/'$pop'}\
  END{for(i=NR;i<='$n';i++) print "\t0"}' $f > X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
done
awk '{printf "%d%s\n",NR,$0}' XX.csv > ../tp_$nx.csv
rm XX.csv
nf=`echo indexes_*.csv | awk '{print NF}'`
#
cd ..
plot in_$nx "infected"
plot in_$nx "infected" .4
plot tp_$nx "test positive" .02
plot tp_$nx "test positive"
done
#
# fi
#
# for cc in fair worse; do
for cc in fair ; do
outfn=in_${cc}_A_O${gf}
n=0
echo "\"day\"" > $outfn.csv
for ((x=0;x<$tl;x++)); do
  for y in {1..4}; do echo $y | awk '{printf "%.2f\n",$1/4+'$x'}' >> $outfn.csv; done
done
for ff in in_${cc}_[0-9]*_O${gf}.csv; do
  vp=`echo $ff | cut -d_ -f3`
  awk 'BEGIN{printf "\t\"%.1f%%\"\n",'$vp'/10}\
{z+=.25;if($1==z){s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}}\
END{for(x=z+.25;x<='$tl';x+=.25)print "\t0"}' $ff > X$vp.csv
done
lam $outfn.csv X??.csv > XX.csv; mv XX.csv $outfn.csv; rm X*.csv
nf=`head -1 $outfn.csv | wc -w`
plotA "infected"
plotA "infected" .4
done
#
# for cc in fair worse; do
for cc in fair ; do
outfn=tp_${cc}_A_O${gf}
n=0
echo "\"day\"" > $outfn.csv
for ((x=1;x<=${tl};x++)); do echo $x >> $outfn.csv; done
for ff in tp_${cc}_[0-9]*_O${gf}.csv; do
  vp=`echo $ff | cut -d_ -f3`
  awk 'BEGIN{printf "\t\"%.1f%%\"\n",'$vp'/10}\
{z++;if($1==z){s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.8f\n",s/(NF-1)}}\
END{for(x=z+1;x<='$tl';x++)print "\t0"}' $ff > X$vp.csv
done
lam $outfn.csv X??.csv > XX.csv; mv XX.csv $outfn.csv; rm X*.csv
nf=`head -1 $outfn.csv | wc -w`
plotA "test positive"
plotA "test positive" .02
done
open $dst