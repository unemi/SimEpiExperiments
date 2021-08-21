#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/LongMove1"
gnuplot <<EOF > $dst/AverageA.svg
set terminal svg size 640 480 fontscale 1.667
set key at graph 0.22,0.96 spacing 1.2
set style data lines
set xlabel "経過日数"
set ylabel "人口に対する感染者数の割合 (%)"
set xrange [:200]
plot for [i=10:0:-1] 'infected' using 1:i+2 title sprintf("%d%%",i)\
 lw 3 lc rgb hsv2rgb(.7-i*0.07,1,.8)
EOF