#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/Gather2"
rm -f peak
foreach i (1 2 3)
   awk -F\	 '{printf "\t%s\t%s\n",$4,$7}' Gather$i/peak > X$i
end
lam X? | awk '{printf "%d%s\n",(NR-1)*2,$0}' > peakDayFG
rm X?
gnuplot <<EOF > $dst/PeakDayF.svg
set terminal svg size 640 480
set style data boxerrorbars
set boxwidth 0.6
set style fill solid .75
set key left
set xlabel "gathering frequency"
set ylabel "peak day"
set xtics scale 0 2
set xrange [-1:41]
set yrange [0:200]
plot 'peakDayFG' using (\$1-.6):2:3 title "10,000",\
 '' using 1:4:5 title "40,000",\
 '' using (\$1+.6):6:7 title "90,000"
EOF
