#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
echo "" > testPositiveAve
set n=0
foreach f (MyResult_??/daily_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
foreach d (MyResult_??)
cd $d
#
foreach f (daily_*.csv)
  awk -F, '$1>0{printf "\t%.4f\n",$2/'$pop'}\
  END{for(i=NR;i<=366;i++)print "\t0"}' $f > X$f
end
lam X*.csv | awk '{printf "%d%s\n",NR,$0}' > testPositive
rm X*.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.4f\n",s/(NF-1)}' testPositive > testPositiveAve
#
set nn=`echo $d | cut -d_ -f2`
set nx=`echo $nn | awk '{printf "%d-%d days",$1*10,$1*50}'`
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot t$nn.svg 
gnuplot <<EOF > $dst/t$nn.svg
set terminal svg size 640 240
set label "Population size = ${pop}00\ninfection rate = 60%" at screen .5,.85 center
unset key
set style data lines
set xlabel "days"
set ylabel "test positive (%)"
set xrange [:365]
set label "${nx}" at graph .025,.85
plot for [i=2:(${nf}+1)] 'testPositive' using 1:i
EOF
lam ../testPositiveAve testPositiveAve > ../testPositiveAve2
rm testPositiveAve
cd ..
mv -f testPositiveAve2 testPositiveAve
end
#
awk '{printf "%d%s\n",NR,$0}' testPositiveAve > testPositive
rm testPositiveAve
set nf=`echo MyResult_?? | awk '{print NF}'`
echo plot TPAverage.svg 
gnuplot <<EOF > $dst/TPAverage.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00\ninfection rate = 60%" at screen .5,.88 center
set key left title "immunity"
set style data lines
set xlabel "days"
set ylabel "test positive (%)"
set xrange [:365]
plot for [i=${nf}:1:-1] 'testPositive' using 1:i+1\
 title sprintf("%d-%d days",i*10,i*50)\
 lc rgb hsv2rgb(.8-i*.8/${nf},1,.8)
EOF
open $dst
