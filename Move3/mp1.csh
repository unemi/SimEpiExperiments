#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/LongMove3"
rm -f peak
foreach d (MyResult??)
pushd $d > /dev/null
#
set nn=`echo $d | cut -c9-`
set ns=`echo indexes_*.csv | awk '{print NF}'`
foreach f (indexes_*.csv)
awk -F, '$1>0{if (x < $2+$3) {x = $2+$3;s=$1}}\
END{printf "%d %d %d\n",x,$4+$5,s}' $f >> X
end
awk '{x += $1; y += $2; z += $3; x2 += $1*$1; y2 += $2*$2; z2 += $3*$3}\
END{x/='$ns';y /= '$ns';z /= '$ns';x2 /= '$ns';y2 /= '$ns';z2 /= '$ns';\
printf "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n",30-'$nn'*5,\
x/900,y/900,z/16,sqrt(x2-x*x)/900,sqrt(y2-y*y)/900,sqrt(z2-z*z)/16}' X >> ../../Move3/peak
rm X
popd > /dev/null
end
gnuplot <<EOF > $dst/Peak.svg
set terminal svg size 640 360
set style data boxerrorbars
set boxwidth 1.5
set style fill solid .75
set key left
set xlabel "travel distance"
set ylabel "infected (%)"
set y2label "peak day"
set y2tics 50
set ytics nomirror
set xtics scale 0 5
set xrange [-3:33]
set yrange [0:*]
plot 'peak' using (\$1-1.5):2:5 title "peak", '' using 1:3:6 title "total in 200th day",\
 '' using (\$1+1.5):4:7 title "peak day" axis x1y2
EOF
