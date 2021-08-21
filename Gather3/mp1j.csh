#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=900
gnuplot <<EOF > $dst/11XX\ 第4回GathF3Peak.svg
set terminal svg size 640 360
set label "人口 ${pop}00人" at screen .5,.9 center
set style data boxerrorbars
set boxwidth .6
set style fill solid .75
set key at screen 0.0,0.95 left
set xlabel "集会の頻度"
set ylabel "感染率 (%)"
set y2label "ピーク日付"
set y2tics 50
set ytics nomirror
set xtics scale 0 2
set xrange [-1:41]
set yrange [0:*]
set y2range [0:200]
plot 'peak' using (\$1-.6):2:5 title "ピーク時感染率",\
 '' using 1:3:6 title "200日累積感染率",\
 '' using (\$1+.6):4:7 title "ピーク日付" axis x1y2
EOF
