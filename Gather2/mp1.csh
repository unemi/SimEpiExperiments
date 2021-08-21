#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/Gather2"
set pop=400
rm -f peak
foreach d (MyResult??)
cd $d
#
set nn=`echo $d | cut -c9-`
set ns=`echo indexes_*.csv | awk '{print NF}'`
foreach f (indexes_*.csv)
awk -F, '$1>0{if (x < $2+$3) {x = $2+$3;s=$1}}\
END{printf "%d %d %d\n",x,$4+$5,s}' $f >> X
end
awk '{x += $1; y += $2; z += $3; x2 += $1*$1; y2 += $2*$2; z2 += $3*$3}\
END{x/='$ns';y /= '$ns';z /= '$ns';x2 /= '$ns';y2 /= '$ns';z2 /= '$ns';\
printf "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n",'$nn',\
x/'$pop',y/'$pop',z/16,sqrt(x2-x*x)/'$pop',sqrt(y2-y*y)/'$pop',sqrt(z2-z*z)/16}' X >> ../peak
rm X
cd ..
end
gnuplot <<EOF > $dst/Peak.svg
set terminal svg size 640 360
set label "Population size = ${pop}00" at screen .5,.9 center
set style data boxerrorbars
set boxwidth .6
set style fill solid .75
set key at graph .35,.95
set xlabel "gathering frequency (%)"
set ylabel "infected (%)"
set y2label "peak day"
set y2tics 50
set ytics nomirror
set xtics scale 0 2
set xrange [-1:41]
set yrange [0:*]
plot 'peak' using (\$1-.6):2:5 title "peak", '' using 1:3:6 title "total in 200th day",\
 '' using (\$1+.6):4:7 title "peak day" axis x1y2
EOF
