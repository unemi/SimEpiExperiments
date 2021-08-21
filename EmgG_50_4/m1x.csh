#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
set nf=`echo MyResult_?? | awk '{print NF}'`
gnuplot <<EOF > $dst/Average.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00" at screen .5,.88 center
set key right title 'infection rate'
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
plot for [i=${nf}:1:-1] 'infected' using 1:i+1 \
 title sprintf("%d%%",i*10+30)\
 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8),\
 for [i=${nf}:1:-1] '../EmgG_100_4/infected' using 1:i+1 notitle\
 dt 2 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8)
EOF
gnuplot <<EOF > $dst/Average2.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00" at screen .5,.88 center
set key right title 'infection rate'
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:100]
set yrange [:1]
plot for [i=${nf}:1:-1] 'infected' using 1:i+1 \
 title sprintf("%d%%",i*10+30)\
 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8),\
 for [i=${nf}:1:-1] '../EmgG_100_4/infected' using 1:i+1 notitle\
 dt 2 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8)
EOF
open $dst
