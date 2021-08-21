#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
set md=`pwd | awk -F/ '{split($NF,a,"_");print a[2]}'`
echo "" > infecAve
foreach d (MyResult_??)
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
set nn=`echo $d | cut -d_ -f2`
set nx=`echo $nn $md | awk '{printf "%d,%d\n",$2-$1*$2/10,$2+$1*(150-$2)/10}'`
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
set key left
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
plot for [i=1:${nf}] 'infected' using 1:i+1 \
 title sprintf("%d,%d",${md}-i*${md}/10,${md}+i*(150-${md})/10)\
 lc rgb hsv2rgb((i-1)*.8/${nf},1,.8)
EOF
# echo plot Average2.svg 
# gnuplot <<EOF > $dst/Average2.svg 
# set terminal svg size 640 300
# set label "Population size = ${pop}00" at screen .5,.88 center
# set key left
# set style data lines
# set xlabel "days"
# set ylabel "infected (%)"
# set xrange [:200]
# set yrange [0:1]
# plot for [i=1:${nf}] 'infected' using 1:i+1 title sprintf("%d",i*10)\
#  lc rgb hsv2rgb((i-1)*.8/${nf},1,.8)
# EOF
