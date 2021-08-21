#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
set nf=`echo MyResult?? | awk '{print NF}'`
gnuplot <<EOF > $dst/Average2.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00" at screen .5,.88 center
set key right
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
set yrange [:1]
plot for [i=0:${nf}] 'infected' using 1:i+2 title sprintf("%d%%",i*10)\
 lc rgb hsv2rgb(i*.8/${nf},1,.8)
EOF