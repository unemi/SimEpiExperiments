#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/LongMove1"
rm -f peak
foreach d (MyResult0??)
cd $d
#
set nn=`echo $d | cut -c10-`
set ns=`echo indexes_*.csv | awk '{print NF}'`
foreach f (indexes_*.csv)
awk -F, '$1>0{if (x < $2+$3) {x = $2+$3;s=$1} if ($1==3200)y=$4+$5}\
END{printf "%d %d %d %d\n",x,y,$4+$5,s}' $f >> X
end
awk '{for(i=1;i<5;i++){x[i]+=$i;x2[i]+=$i*$i}}\
END{printf "%.1f",'$nn'/10;\
  for(i=1;i<5;i++){x[i]/='$ns';x2[i]/='$ns';b=(i<4)?400:16;\
    printf "\t%.3f\t%.3f",x[i]/b,sqrt(x2[i]-x[i]*x[i])/b}\
  print ""}' X >> ../peak
rm X
cd ..
end
gnuplot <<EOF > $dst/Peak2.svg
set terminal svg size 640 360
set style data boxerrorbars
set boxwidth 0.1
set style fill solid .75
set key left
set xlabel "travel frequency (%)"
set ylabel "infected (%)"
set y2label "peak day"
set y2tics 50
set ytics nomirror
set xtics scale 0 .5
set xrange [0.75:4.25]
set yrange [0:*]
plot 'peak' using (column(1)-.15):2:3 title "peak",\
 '' using (column(1)-.05):4:5 title "total in 200th day",\
 '' using (column(1)+.05):6:7 title "total in 400th day",\
 '' using (column(1)+.15):8:9 title "peak day" axis x1y2
EOF
