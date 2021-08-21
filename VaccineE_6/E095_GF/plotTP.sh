#! /bin/bash
popN=`pwd | awk -F/ '{d=$(NF-1);print substr(d,length(d),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
ed=22
ld=95
tl=0
for f in MyResult_??/daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $nn ]; then tl=$nn; fi
done
# goto TPAV
awk -F, 'NR>1 && $1<='$ld'{printf "%d\t%.8f\n",$1,$2/'$pop'}'\
  MyResult_00/daily_1.csv > tpToLD.csv
echo '"day"' > X.csv
for ((x=$ld;x<=$tl;x++)); do echo $x >> X.csv; done
for d in MyResult_??; do
cd $d
ns=`echo daily_*.csv | awk '{print NF}'`
rm -f XX.csv
touch XX.csv
for f in daily_*.csv; do
  awk -F, '$1>='$ld'{printf "%s \n",$2}' $f > A.csv
  lam XX.csv A.csv > X2.csv
  mv X2.csv XX.csv
done
echo $d | awk -F_ '{printf "\t\"%d%%\"\n",$2+1}' > A.csv
awk '{s=0;for(i=1;i<=NF;i++)s+=$i;printf "\t%.8f\n",s/'$ns'/'$pop'}' XX.csv >> A.csv
rm XX.csv
cd ..
done
lam X.csv MyResult_??/A.csv > testPositive.csv
rm X.csv MyResult_??/A.csv
nf=`head -1 testPositive.csv | awk '{print NF}'`
#
echo plot TPAverage.svg
gnuplot <<EOF > TPAverage.svg
set terminal svg size 640 300
set key right
set style data lines
set ylabel "test positive (%)"
set xrange [1:${tl}]
set yrange [:.02]
set label "population size = `expr $pop / 10`,000" at screen .5,.88 center
set label "→ emergency declaration" at $ed,graph .78
set label "→ lift declaration" at $ld,graph .3
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgb "red"
set arrow from $ld,graph 0 to $ld,graph .4 nohead lc rgb "#008800"
set xtics ("Jan 7" $ed, "Feb 7" $ed+31, "Mar 7" $ed+59, "Apr 1" $ed+84, "May 1" $ed+114)
plot for [i=$nf:2:-1] 'testPositive.csv' using 1:i \
 title columnhead lc rgb hsv2rgb(($nf-i)/($nf-1.),1,.8),\
 'tpToLD.csv' using 1:2 notitle lc rgb "#999999",\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo weekly" lc rgb "#006600",\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo daily" lc rgb "#006600" dt 3
EOF
