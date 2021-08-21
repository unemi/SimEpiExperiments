#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=900
#
set nf=`echo MyResult?? | awk '{print NF}'`
gnuplot <<EOF > $dst/11XX\ 第4回GathS3Average.svg 
set terminal svg size 640 360
set label "Population size = ${pop}00" at screen .8,.88 left
set key left title "frequency"
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
plot for [i=${nf}:0:-1] 'infected' using 1:i+2 title sprintf("%d",i)\
 lw 2 lc rgb hsv2rgb(.9-i*.9/${nf},1,.8)
EOF