#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
# goto TPAV
echo "" > testPositiveAve
set tl=0
foreach f (MyResult_??/daily_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($tl < $nn) set tl=$nn
end
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
setenv LANG C
set nn=`echo $d | cut -d_ -f2`
set gf=`echo $d | awk -F_ '{printf "%.1f\n",($2*5+5)/10}'`
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot t$nn.svg 
gnuplot <<EOF > $dst/t$nn.svg
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
unset key
set style data lines
set ylabel "test positive (%)"
set label "${gf}" at graph .025,.85
set xrange [1:${tl}]
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
  echo $d | awk -F_ '{printf "\t%.1f",($2*5+5)/10}' >> testPositive
end
echo "" >> testPositive
awk '{printf "%d%s\n",NR,$0}' testPositiveAve >> testPositive
rm testPositiveAve
#
TPAV:
set nf=`echo MyResult_?? | awk '{print NF}'`
setenv LANG ja_JP.UTF-8
echo plot TPAverage.svg
gnuplot <<EOF > $dst/TPAverage.svg 
set terminal svg size 640 300
set label "population size = ${pop}00" at screen .5,.88 center
set label "→ restriction ${gf}%" at 20,graph .15
set key right title "start and perform"
set style data lines
set ylabel "test positive (%)"
set xrange [1:${tl}]
plot for [i=1:${nf}] 'testPositive' using 1:i+1 \
 title columnhead lc rgb hsv2rgb(i*.8/5,1,.8),\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/tkyWeekly.csv'\
  using (\$1 - 333):(\$2 / 130000.0) title "Tokyo" lc rgb "#008800" lw 2
EOF
open $dst
