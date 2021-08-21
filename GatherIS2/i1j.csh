#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
#
set nf=`echo MyResult?? | awk '{print NF}'`
gnuplot <<EOF > ${dst}/11XX\ 第4回GathS2Infects.svg 
set terminal svg size 640 360
set label "人口 ${pop}00人" at screen .5,.9 center
set style data boxerrorbars
set boxwidth .2
set style fill solid .75
set key at screen 0.,.95 left
set xlabel "集会の規模"
set ylabel "感染者中の割合 (%)"
set y2label "最大感染数 (人)"
set xtics scale 0 1
set ytics nomirror
set y2tics 10
set xrange [-.5:10.5]
set yrange [0:*]
set y2range [0:90]
plot 'infects' using (\$1-.3):2:3 title "感染0人",\
 '' using (\$1-.1):4:5 title "1人",\
 '' using (\$1+.1):6:7 title "2人",\
 '' using (\$1+.3):8:9 title "最大感染数" axis x1y2
EOF