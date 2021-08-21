#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
awk -F, 'NR>1{d[NR-2]=$2}\
END{for(i=0;i<NR-1;i++){s=n=0;for(j=i-3;j<i+4;j++)if(i>=0&&i<NR-1){s+=d[j];n++}\
printf "%d\t%d\n",i,s/n}}' \
 ~/Research/SimEpidemicPJ/内閣府PJ/統計データ/pcr_positive_daily.csv > realTP_J
awk -F, '{d[NR-1]=$2*3}\
END{for(i=0;i<NR;i++){s=n=0;for(j=i-3;j<i+4;j++)if(i>=0&&i<NR){s+=d[j];n++}\
printf "\t%d\n",s/n}}' ~/Research/SimEpidemicPJ/内閣府PJ/統計データ/tky.csv > realTP_T
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
plot\
 '../ScenJim60_3/testPositive' using 1:4 title "60% 30-150 days" lc rgbcolor "#0066ff",\
 'testPositive' using 1:4 title "55% 30-150 days" lc rgbcolor "#666666",\
 '../ScenJim50_3/testPositive' using 1:4 title "50% 30-150 days" lc rgbcolor "#aa4400",\
 'realTP' using 1:2 title "Japan" axis x1y2 lw 2 lc rgbcolor "red",\
 'realTP' using 1:3 title "Tokyo x3" axis x1y2 lw 2 lc rgbcolor "#008800"\
EOF
open $dst
