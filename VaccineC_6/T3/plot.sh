#! /bin/bash
# dst="$HOME/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{printf "%s_%s",$(NF-1),$NF}'`
# if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);printf "%d\n",n*n*100}'`
ed=22
nyd=`expr $ed - 6`
wd=`expr $ed - 4`
ld=`expr $ed + 52`
vd=`expr $ed + 94`
tl=0
for f in MyResult_??/daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $nn ]; then tl=$nn; fi
done
# goto TPAV
echo '"day"' > X.csv
for ((x=1;x<=$tl;x++)); do echo $x >> X.csv; done
for d in MyResult_??; do
cd $d
ns=`echo daily_*.csv | awk '{print NF}'`
rm -f XX.csv
touch XX.csv
for f in daily_*.csv; do
  awk -F, '$1>0{printf "%s \n",$2}' $f > A.csv
  lam XX.csv A.csv > X2.csv
  mv X2.csv XX.csv
done
echo $d | awk -F_ '{printf "\t\"%.1f%%\"\n",$2*.5+1.5}' > A.csv
awk '{s=0;for(i=1;i<=NF;i++)s+=$i;printf "\t%.8f\n",s/'$ns'/'$pop'}' XX.csv >> A.csv
rm XX.csv
cd ..
done
lam X.csv MyResult_??/A.csv > testPositive.csv
rm X.csv MyResult_??/A.csv
nf=`head -1 testPositive.csv | awk '{print NF}'`
#
echo plot TPAverage.svg
# gnuplot <<EOF > $dst/TPAverage.svg
#
gnuplot <<EOF > TPAverage.svg
set terminal svg size 640 300
set key right
set style data lines
set ylabel "test positive (%)"
set xrange [1:${tl}]
set yrange [:.015]
set label "population size = `expr $pop / 10`,000" at screen .5,.88 center
set label "→ emergency declaration" at $ed,graph .2
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgb "red"
set xtics ("Dec 24" $ed-14, "Jan 7" $ed, "Jan 23" $ed+16,\
 "Feb 7" $ed+31, "Feb 21" $ed+45)
plot for [i=$nf:2:-1] 'testPositive.csv' using 1:i \
 title columnhead lc rgb hsv2rgb(($nf-i)*.8/($nf-2),1,.8),\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2
EOF
# open $dst
