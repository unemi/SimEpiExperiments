#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/LongMove1"
gnuplot <<EOF > $dst/AverageA-en.svg
set terminal svg size 640 480 fontscale 1.667
set key at graph 0.3,0.96 spacing 1.2 title "Travel frequency"
set style data lines
set xlabel "Days"
set ylabel "Infected (%)"
set xrange [:200]
plot for [i=10:0:-1] 'infected' using 1:i+2 title sprintf("%d%%",i)\
 lw 3 lc rgb hsv2rgb(.7-i*0.07,1,.8)
EOF