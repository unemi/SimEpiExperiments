#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
gnuplot <<EOF > $dst/`pwd | awk -F/ '{print $NF}'`PeakE.svg
set terminal svg size 640 360
set label "Population size = ${pop}00" at screen .5,.9 center
set style data boxerrorbars
set boxwidth 3
set style fill solid .75
set key right
set xlabel "test rate (% in symptomatic patients per day)"
set ylabel "infected (%)"
set y2label "peak day"
set y2tics 50
set ytics nomirror
set xtics scale 0 10
set xrange [5:95]
set yrange [0:*]
set y2range [0:200]
plot 'peak' using (\$1-3):2:5 title "peak", '' using 1:3:6 title "total in 200th day",\
 '' using (\$1+3):4:7 title "peak day" axis x1y2
EOF
gnuplot <<EOF > $dst/`pwd | awk -F/ '{print $NF}'`PeakJ.svg
set terminal svg size 640 360
set label "Population size = ${pop}00" at screen .5,.9 center
set style data boxerrorbars
set boxwidth 3
set style fill solid .75
set key right
set xlabel "検査率 (発症者1日当たり%)"
set ylabel "感染率 (%)"
set y2label "ピーク日付"
set y2tics 50
set ytics nomirror
set xtics scale 0 10
set xrange [5:95]
set yrange [0:*]
set y2range [0:200]
plot 'peak' using (\$1-3):2:5 title "ピーク時", '' using 1:3:6 title "200日目の累積",\
 '' using (\$1+3):4:7 title "ピーク日付" axis x1y2
EOF
