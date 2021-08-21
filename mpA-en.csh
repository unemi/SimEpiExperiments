#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/LongMove2"
# rm -f peak
# foreach i (0 1 2)
#   awk -F\	 '{printf "\t%s\t%s\n",$4,$7}' Move$i/peak > X$i
# end
# lam X? | awk '{printf "%d%s\n",NR-1,$0}' > peakDay
# rm X?
gnuplot <<EOF > $dst/PeakDayA-en.svg
set terminal svg size 640 480 fontscale 1.667
set style data boxerrorbars
set boxwidth 0.26
set style fill solid .5
set key at graph 0.25,0.95 spacing 1.33 title "Population size"
set xlabel "Travel frequency (%)"
set ylabel "Peak day"
set xtics scale 0 1
set xrange [-0.5:10.5]
set yrange [0:200]
plot 'peakDay' using (\$1-.3):2:3 title "10,000" lw 2 fc rgb "#0022CC",\
 '' using 1:4:5 title "40,000" lw 2 fc rgb "#009900",\
 '' using (\$1+.3):6:7 title "90,000" lw 2 fc rgb "#BB7700"
EOF
