#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/Gather2"
rm -f peak
foreach i (1 2 3)
   awk -F\	 '{printf "\t%s\t%s\n",$4,$7}' GatherS$i/peak > X$i
end
lam X? | awk '{printf "%d%s\n",NR-1,$0}' > peakDaySG
rm X?
gnuplot <<EOF > $dst/PeakDayS.svg
set terminal svg size 640 480
set style data boxerrorbars
set boxwidth 0.3
set style fill solid .75
set key left
set xlabel "gathering size"
set ylabel "peak day"
set xtics scale 0 1
set xrange [-0.5:10.5]
set yrange [0:200]
plot 'peakDaySG' using (\$1-.3):2:3 title "10,000",\
 '' using 1:4:5 title "40,000",\
 '' using (\$1+.3):6:7 title "90,000"
EOF
