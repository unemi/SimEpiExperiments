#! /bin/bash
pp=`pwd | awk -F/ '{print substr($NF,length($NF),1)}'`
pop=$((pp*pp*100))
ed=22 # emergency declaration day (January 7)
rd=95 # lifting day (March 21)
md=117 # stricter measures day (April 12)
vd=131 # vaccination start day (April 26)
tl=0
for f in MyResult_??/daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $nn ]; then tl=$nn; fi
done
if [ ! -f testPositive.csv ]; then
# goto TPAV
echo '"day"' > X.csv
for ((x=1;x<=$tl;x++)); do echo $x >> X.csv; done
for d in MyResult_??; do
cd $d
rm -f XX.csv
touch XX.csv
for f in daily_*.csv; do
  awk -F, '$1>0{printf "%s \n",$2}' $f > A.csv
  lam XX.csv A.csv > X2.csv
  mv X2.csv XX.csv
done
echo $d | awk -F_ '{printf "\t\"%d%%\"\n",$2*20}' > A.csv
awk '{s=0;for(i=1;i<=NF;i++)s+=$i;printf "\t%.8f\n",s/NF/'$pop'}' XX.csv >> A.csv
rm XX.csv
cd ..
done
lam X.csv MyResult_??/A.csv > testPositive.csv
rm X.csv MyResult_??/A.csv
fi
#
nf=`head -1 testPositive.csv | awk '{print NF}'`
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
echo plot $1.svg
gnuplot <<EOF > $1.svg
set terminal svg size 640 300
set key right title "noVax cluster rate"
set style data lines
set ylabel "test positive (%)"
set xrange [1:${tl}]
set yrange [:.02]
set label "population size = `expr $pop / 10`,000" at screen .5,.88 center
set label "→ emergency declaration" at $ed,graph .85
set label "→ lift declaration" at $rd,graph .8
set label "→ stricter measures" at $md,graph .75
set label "→ vaccine" at $vd,graph .7
set arrow from $ed,graph 0 to $ed,graph .9 nohead lc rgb "#884400"
set arrow from $rd,graph 0 to $rd,graph .85 nohead lc rgb "#004488"
set arrow from $md,graph 0 to $md,graph .8 nohead lc rgb "#888800"
set arrow from $vd,graph 0 to $vd,graph .75 nohead lc rgb "#880088"
set xtics ($xmarks)
if ("$2" eq "log") { set logscale y }
plot for [i=2:$nf] 'testPositive.csv' using 1:i \
 title columnhead lc rgb hsv2rgb((i-2.)/($nf-1),1,.8),\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2
EOF
}
makePlot TPAverage linear
makePlot TPAverageLog log
