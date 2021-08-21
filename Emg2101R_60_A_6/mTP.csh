#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
set gf=`pwd | awk -F_ '{print 100-$2}'`
echo "" > testPositiveAve
# goto TPAV
#
set n=0
foreach f (MyResult_??/daily_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
foreach d (MyResult_??)
cd $d
#
touch XX.csv
foreach f (daily_*.csv)
  awk -F, '$1>0{printf "\t%.6f\n",$3/'$pop'}\
  END{for(i=NR;i<=201;i++)print "\t0"}' $f > X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
end
awk '{printf "%d%s\n",NR,$0}' XX.csv > testPositive
rm XX.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' testPositive > testPositiveAve
#
setenv LANG C
set nn=`echo $d | cut -d_ -f2`
set df=`expr $nn \* 7 + 58`
set nx=`date -j -v+${df}d 121801002020 "+%b %e"`
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot t$nn.svg 
gnuplot <<EOF > $dst/t$nn.svg
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
unset key
set style data lines
set ylabel "test positive (%)"
set xrange [:200]
set xtics ("Jan 7" 20, "Feb 7" 51, "Mar 7" 79, "Mar 28" 100, "Apr 18" 121,\
 "May 9" 142, "May 30" 163, "Jun 20" 184)
set arrow from 20,graph 0 to 20,graph 1 nohead lc rgbcolor "red"
set arrow from ${df},graph 0 to ${df},graph 1 nohead lc rgbcolor "#008800"
set label "${nx}" at graph .025,.85
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
  set nn=`echo $d | cut -d_ -f2`
  set df=`expr $nn \* 7 + 58`
  date -j -v+${df}d 121801002020 "+%b %e" | awk '{printf "\t\"%s %s\"",$1,$2}' >> testPositive
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
set key right title "releasing date"
set style data lines
set ylabel "test positive (%)"
set xrange [:200]
set yrange [0:0.03]
set xtics ("Jan 7" 20, "Feb 7" 51, "Mar 7" 79, "Mar 28" 100, "Apr 18" 121,\
 "May 9" 142, "May 30" 163, "Jun 20" 184)
set arrow from 20,graph 0 to 20,graph 1 nohead lc rgbcolor "red"
set for [i=1:${nf}] arrow from i*7+51,graph .01 to i*7+51,graph .33 nohead\
 lc rgb hsv2rgb(i*.8/${nf},1,.8)
plot for [i=1:${nf}] 'testPositive' using 1:i+1 \
 title columnhead lc rgb hsv2rgb(i*.8/${nf},1,.8), \
 '../Emg2101R_50_4/tky202101.csv' using 1:2 title "Tokyo" lc rgb "#008800" lw 2
EOF
open $dst
