#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
awk -F, 'NR>1{printf "%d\t%d\n",NR-2,$2}' ../pcr_positive_daily.csv > realTP_J
awk -F, '{printf "\t%d\n",$2*3}' ~/Research/SimEpidemicPJ/内閣府PJ/統計データ/tky.csv > realTP_T
lam realTP_J realTP_T > realTP
echo plot TPCompare.svg
gnuplot <<EOF > $dst/TPCompare.svg 
set terminal svg size 720 300
set label "test positive" at screen .5,.85 center
set key left
set style data lines
set xlabel "days"
set ylabel "simulation"
set y2label "real data"
set ytics nomirror
set y2tics 500
set xrange [:365]
plot 'testPositive' using 1:9 title "simulation (80%)",\
 'testPositive' using 1:8 title "(70%)",\
 'testPositive' using 1:7 title "(60%)",\
 'testPositive' using 1:6 title "(50%)",\
 'testPositive' using 1:5 title "(40%)",\
 'realTP' using 1:2 title "Japan" axis x1y2 lc rgbcolor "red",\
 'realTP' using 1:3 title "Tokyo x3" axis x1y2 lc rgbcolor "#008800",\
EOF
open $dst
