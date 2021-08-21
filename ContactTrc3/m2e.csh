#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
#
set nf=`echo MyResult?? | awk '{print NF}'`
gnuplot <<EOF > $dst/11XX\ 第4回Cont3Average2E.svg 
set terminal svg size 640 360
set label "Population size ${pop}00" at screen .75,.88 left
set nokey
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
set yrange [:1]
plot for [i=0:${nf}] 'infected' using 1:i+2 title sprintf("%d%%",i*10)\
 lw 2 lc rgb hsv2rgb(i*.8/${nf},1,.8)
EOF