#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
echo "" > infecAve
foreach d (MyResult_??)
cd $d
#
set n=0
foreach f (indexes_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
touch XX.csv
foreach f (indexes_*.csv)
  awk -F, '$1>0{x+=$2+$3;n++;if($1%4==0){printf "\t%.4f\n",x/n/'$pop'.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/4;i<$1/4;i++) print "\t0"}' >> X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
end
awk '{printf "%.2f%s\n",NR/4.,$0}' XX.csv > infected
rm XX.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.4f\n",s/(NF-1)}\
END{for(i=NR;i<=800;i++) print "\t0"}' infected > infecAve
#
set nn=`echo $d | cut -d_ -f2`
set nx=`echo $nn | awk '{printf "%d%%\n",(10-$1)*10}'`
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot m$nn.svg 
gnuplot <<EOF > $dst/m$nn.svg
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
unset key
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
set label "$nx" at graph .025,.85
plot for [i=2:(${nf}+1)] 'infected' using 1:i
EOF
lam ../infecAve infecAve > ../infecAve2
rm infecAve
cd ..
mv -f infecAve2 infecAve
end
#
awk '{printf "%.2f%s\n",NR/4.,$0}' infecAve > infected
rm infecAve
set nf=`echo MyResult_?? | awk '{print NF}'`
echo plot Average.svg 
gnuplot <<EOF > $dst/Average.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00" at screen .5,.88 center
set key right
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
plot for [i=${nf}:1:-1] 'infected' using 1:i+1 \
 title sprintf("%d%%",(11-i)*10)\
 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8)
EOF
gnuplot <<EOF > $dst/Average2.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00" at screen .5,.88 center
set key right
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:50]
plot for [i=${nf}:1:-1] 'infected' using 1:i+1 \
 title sprintf("%d%%",(11-i)*10)\
 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8)
EOF
open $dst