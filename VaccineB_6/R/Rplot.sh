#! /bin/bash
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/R_GX_167"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`pwd | awk -F/ '{n=substr($(NF-1),length($(NF-1)),1);printf "%d\n",n*n*100}'`
for gf in 2 3 4; do
gnuplot > $dst/I_$gf.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00\nGathering frequency = ${gf}.0%" at screen .5,.85 center
set key right title "Lifting date"
set style data lines
set ylabel "infected (%)"
set xrange [:167]
set yrange [:.4]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .1
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set for [i=0:3] arrow from i*7+74,graph 0 to i*7+74,graph .4 nohead lc rgb hsv2rgb(i*.8/4,1,.8)
plot '../R_G074_167/infected.csv' using 1:$gf title "Feb 28" lc rgb hsv2rgb(0,1,.8),\
     '../R_G081_167/infected.csv' using 1:$gf title "Mar 7" lc rgb hsv2rgb(1./4,1,.8),\
     '../R_G088_167/infected.csv' using 1:$gf title "Mar 14" lc rgb hsv2rgb(2./4,1,.8),\
     '../R_G095_167/infected.csv' using 1:$gf title "Mar 21" lc rgb hsv2rgb(3./4,1,.8)
EOF
gnuplot > $dst/T_$gf.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00\nGathering frequency = ${gf}.0%" at screen .5,.85 center
set key right title "Lifting date"
set style data lines
set ylabel "test positive (%)"
set xrange [:167]
set yrange [:.02]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .1
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set for [i=0:3] arrow from i*7+74,graph 0 to i*7+74,graph .4 nohead lc rgb hsv2rgb(i*.8/4,1,.8)
plot '../R_G074_167/testPositive.csv' using 1:$gf title "Feb 28" lc rgb hsv2rgb(0,1,.8),\
     '../R_G081_167/testPositive.csv' using 1:$gf title "Mar 7" lc rgb hsv2rgb(1./4,1,.8),\
     '../R_G088_167/testPositive.csv' using 1:$gf title "Mar 14" lc rgb hsv2rgb(2./4,1,.8),\
     '../R_G095_167/testPositive.csv' using 1:$gf title "Mar 21" lc rgb hsv2rgb(3./4,1,.8)
EOF
done
open $dst
