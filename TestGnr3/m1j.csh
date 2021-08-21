#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
set nf=`echo MyResult?? | awk '{print NF}'`
gnuplot <<EOF > $dst/11XX\ 第4回Test3Average.svg 
set terminal svg size 640 360
set label "人口 ${pop}00人" at screen .5,.88 center
set key left title "検査率"
set style data lines
set xlabel "経過日数"
set ylabel "感染率 (%)"
set xrange [:200]
plot for [i=0:${nf}] 'infected' using 1:i+2 title sprintf("%d%%",i)\
 lw 2 lc rgb hsv2rgb(i*.8/${nf},1,.8)
EOF