#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{printf "%s_%s",$(NF-1),$NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);printf "%d\n",n*n*100}'`
set ed=22
set nyd=`expr $ed - 6`
set wd=`expr $ed - 4`
set ld=`expr $ed + 52`
set vd=`expr $ed + 94`
set tl=0
foreach f (MyResult_??/daily_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($tl < $nn) set tl=$nn
end
goto TPAV
echo "" > testPositiveAve
#
foreach d (MyResult_??)
cd $d
#
touch XX.csv
foreach f (daily_*.csv)
  awk -F, '$1>0{printf "\t%.6f\n",$2/'$pop'}\
  END{for(i=NR;i<='$tl';i++)print "\t0"}' $f > X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
end
awk '{printf "%d%s\n",NR,$0}' XX.csv > testPositive
rm XX.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' testPositive > testPositiveAve
#
set nn=`echo $d | cut -d_ -f2`
set gf=`echo $d | awk -F_ '{printf "%.1f\n",($2+6)/10}'`
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot t$nn.svg 
gnuplot <<EOF > $dst/t$nn.svg
set terminal svg size 640 240
unset key
set style data lines
set ylabel "test positive (%)"
set label "${gf}" at graph .025,.85
set xrange [1:${tl}]
# set xrange [1:${vd}+20]
set yrange [:.03]
set label "Population size = ${pop}00" at screen .5,.85 center
set label "→ emergency declaration" at $ed,graph .15
set label "→ lift declaration" at $ld,graph .5
# set label "→ vaccine" at $vd,graph .4
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgb "red"
set arrow from $ld,graph 0 to $ld,graph .6 nohead lc rgb "#008800"
# set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgb "#660088"
set xtics ("Jan 7" $ed, "Feb 7" $ed+31, "Mar 7" $ed+59, "Apr 1" $ed+84)
plot for [i=1:${nf}] 'testPositive' using 1:i+1
EOF
lam ../testPositiveAve testPositiveAve > ../testPositiveAve2
rm testPositiveAve
cd ..
mv -f testPositiveAve2 testPositiveAve
end
#
echo -n "-" > testPositive
foreach d (MyResult_??)
  echo $d | awk -F_ '{printf "\t%.1f",($2+6)/10}' >> testPositive
end
echo "" >> testPositive
awk '{printf "%d%s\n",NR,$0}' testPositiveAve >> testPositive
rm testPositiveAve
#
TPAV:
set nf=`echo MyResult_?? | awk '{print NF}'`
echo plot TPAverage.svg
gnuplot <<EOF > $dst/TPAverage.svg 
set terminal svg size 640 300
set key right
set style data lines
set ylabel "test positive (%)"
set xrange [1:${tl}]
# set xrange [1:${vd}+20]
set yrange [:.02]
set label "population size = `expr $pop / 10`,000" at screen .5,.88 center
set label "→ emergency declaration" at $ed,graph .78
set label "→ lift declaration" at $ld,graph .3
# set label "→ vaccine" at $vd,graph .4
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgb "red"
set arrow from $ed+4,graph 0 to $ed+4,graph .5 nohead lc rgb "#FF4444"
set arrow from $ld,graph 0 to $ld,graph .4 nohead lc rgb "#008800"
# set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgb "#660088"
set xtics ("Jan 7" $ed, "Feb 7" $ed+31, "Mar 7" $ed+59, "Apr 1" $ed+84)
plot for [i=1:${nf}] 'testPositive' using 1:i+1 \
 title columnhead lc rgb hsv2rgb(i*.8/4,1,.8),\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2
#  '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/27大阪府.csv'\
#   using (\$1 - 316 - $ed):(\$2 / 88400.0) title "Oosaka" lc rgb "#880000" lw 2,\
#  '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/23愛知県.csv'\
#   using (\$1 - 316 - $ed):(\$2 / 75400.0) title "Aichi" lc rgb "#0000AA" lw 2,\
#  '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/40福岡県.csv'\
#   using (\$1 - 316 - $ed):(\$2 / 51100.0) title "Fukuoka" lc rgb "#888888" lw 2
EOF
open $dst
