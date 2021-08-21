#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/Gather3"
if (! -d $dst) mkdir -p $dst
set pop=900
echo "" > positAve
foreach d (MyResult??)
cd $d
#
set n=0
foreach f (daily_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
foreach f (daily_*.csv)
  awk -F, '$1>0{x+=$2;n++;if($1%4==0){printf "\t%.2f\n",x/n/'$pop'.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/4;i<$1/4;i++) print "\t0"}' >> X$f
end
lam X*.csv | awk '{printf "%.2f%s\n",NR*4,$0}' > testPositive
rm X*.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.2f\n",s/(NF-1)}\
END{for(i=NR;i<=800;i++) print "\t0"}' testPositive > positAve
#
set nn=`echo $d | cut -c9-`
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot p$nn.svg 
gnuplot <<EOF > $dst/p$nn.svg
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
unset key
set style data lines
set xlabel "days"
set ylabel "test positive (%)"
set xrange [:200]
set label "${nn}%" at graph .025,.85
plot for [i=2:(${nf}+1)] 'testPositive' using 1:i
EOF
lam ../positAve positAve > ../positAve2
rm positAve
cd ..
mv -f positAve2 positAve
end
#
awk '{printf "%.2f%s\n",NR*4,$0}' positAve > testPositive
rm positAve
set nf=`echo MyResult?? | awk '{print NF}'`
echo plot AverageP.svg 
gnuplot <<EOF > $dst/AverageP.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00" at screen .5,.88 center
set key left
set style data lines
set xlabel "days"
set ylabel "test positive (%)"
set xrange [:200]
plot for [i=${nf}:0:-1] 'testPositive' using 1:i+2 title sprintf("%d%%",i*2)\
 lc rgb hsv2rgb(.9-i*.9/${nf},1,.8)
EOF