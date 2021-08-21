#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
set gf=`pwd | awk -F_ '{print 100-$2}'`
set dr=`pwd | awk -F_ '{if(NF>3)print 50+$3;else print 50}'`
echo "" > testPositiveAve
set dly=(0 3 7 10 14 21 28 42 60)
goto TPAV
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
set nn=`echo $d | cut -d_ -f2`
@ i = $nn + 1
set nx=$dly[$i]
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot t$nn.svg 
gnuplot <<EOF > $dst/t$nn.svg
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
unset key
set style data lines
set xlabel "days"
set ylabel "test positive (%)"
set xrange [:200]
set label "${nx} days" at graph .025,.85
plot for [i=1:${nf}] 'testPositive' using 1:i+1
EOF
lam ../testPositiveAve testPositiveAve > ../testPositiveAve2
rm testPositiveAve
cd ..
mv -f testPositiveAve2 testPositiveAve
end
#
echo $dly | awk '{printf "-";for(i=1;i<=NF;i++)printf "\t\"%d days\"",$i;print ""}' > testPositive
awk '{printf "%d%s\n",NR,$0}' testPositiveAve >> testPositive
rm testPositiveAve
#
TPAV:
set v1=`awk '$1==20{s=0;for(i=2;i<=NF;i++)s+=$i;printf "%.6f %%\n",s/(NF-1);exit}' testPositive`
set v2=`awk '$1=='${dr}'{s=0;for(i=2;i<=NF;i++)s+=$i;printf "%.6f %%\n",s/(NF-1);exit}' testPositive`
set nf=`echo MyResult_?? | awk '{print NF}'`
# echo plot TPAverage.svg 
gnuplot <<EOF > $dst/TPAverage.svg 
set terminal svg size 640 300
set label "population size = ${pop}00" at screen .5,.88 center
set label "→ restriction ${gf}%\n${v1}" at 20,graph .15
set label "→ release\n${v2}" at ${dr},graph .7
set key right title "releasing span"
set style data lines
set ylabel "test positive (%)"
set xrange [:200]
set yrange [0:0.03]
set xtics ("Jan 7" 20, "Jan 27" 40, "Feb 16" 60, "Mar 8" 80, "Mar 28" 100,\
 "Apr 17" 120, "May 7" 140, "May 27" 160, "Jun 16" 180)
set arrow from 20,graph 0 to 20,graph 1 nohead lc rgbcolor "red"
set arrow from ${dr},graph 0 to ${dr},graph 1 nohead
plot for [i=1:${nf}] 'testPositive' using 1:i+1 \
 title columnhead lc rgb hsv2rgb(i*.8/${nf},1,.8), \
 '../Emg2101R_50_4/tky202101.csv' using 1:2 title "Tokyo" lc rgb "#008800" lw 2
EOF
# open $dst
