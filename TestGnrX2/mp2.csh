#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
gnuplot <<EOF > $dst/Peak2.svg
set terminal svg size 640 360
set label "Population size = ${pop}00" at screen .5,.9 center
set style data boxerrorbars
set boxwidth .04
set style fill solid .75
# set key at graph .35,.95
set key right
set xlabel "test rate (% in population per day)"
set ylabel "infected (%)"
set y2label "peak day"
set ytics nomirror
set xtics scale 0 .1
set y2tics 10
set xrange [-.05:1.05]
set y2range [100:140]
plot 'peak' using (\$1-.02):2:5 title "peak",\
 '' using (\$1+.02):4:7 title "peak day" axis x1y2
EOF
