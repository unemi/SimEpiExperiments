#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=900
#
set nf=`echo MyResult?? | awk '{print NF}'`
gnuplot <<EOF > $dst/11XX\ 第4回GathF3Average.svg 
set terminal svg size 640 360
set label "人口 ${pop}00人" at screen .8,.88 left
set key at screen .1,.925 left title "頻度"
set style data lines
set xlabel "日"
set ylabel "感染率 (%)"
set xrange [:200]
plot for [i=${nf}:0:-1] 'infected' using 1:i+2 title sprintf("%d",i*2)\
 lw 2 lc rgb hsv2rgb(.9-i*.9/${nf},1,.8)
EOF