#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk -F/ '{split($NF,a,"_");n=a[2];printf "%d\n",n*100}'`
foreach c (4_1 4_2 5_1 5_2)
echo "" > infecAve
foreach d (MyResult_${c}_??)
cd $d
#
set n=0
foreach f (indexes_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
foreach f (indexes_*.csv)
  awk -F, '$1>0{x+=$2+$3;n++;if($1%4==0){printf "\t%.4f\n",x/n/'$pop'.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/4;i<$1/4;i++) print "\t0"}' >> X$f
end
lam X*.csv | awk '{printf "%.2f%s\n",NR/4.,$0}' > infected
rm X*.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.4f\n",s/(NF-1)}\
END{for(i=NR;i<=800;i++) print "\t0"}' infected > infecAve
#
set nn=`echo $d | cut -c9-`
set pd=`echo $nn | awk '{printf "%d\n",$1}'`
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
set label "${pd}0,000 persons / km^2" at graph .75,.85
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
set nf=`echo MyResult_${c}_?? | awk '{print NF}'`
echo plot Average_$c.svg 
gnuplot <<EOF > $dst/Average_$c.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00" at screen .5,.88 center
set key left
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
plot for [i=${nf}:0:-1] 'infected' using 1:i+2 title sprintf("%d0",i+1)\
 lc rgb hsv2rgb(.8-i*.8/${nf},1,.8)
EOF
mv -f infected infected_$c
end
