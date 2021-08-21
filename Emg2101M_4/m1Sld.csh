#! /bin/csh
set dst="~/Research/SimEpidemicPJ/内閣府PJ/AdviseryBoard"
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
set nf=`echo MyResult_?? | awk '{print NF}'`
gnuplot <<EOF > $dst/`pwd | awk -F/ '{print $NF}'`AverageE.svg 
set terminal svg size 640 360
set label "Population size = ${pop}00" at screen .5,.88 center
set key right title "Suppression rate"
set style data lines
set xlabel "days"
set ylabel "infected (%)"
set xrange [:200]
plot for [i=${nf}:1:-1] 'infected' using 1:i+1 \
 title sprintf("%d%%",(11-i)*10)\
 lw 2 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8)
EOF
gnuplot <<EOF > $dst/`pwd | awk -F/ '{print $NF}'`AverageJ.svg 
set terminal svg size 640 360
set label "人口 ${pop}00人" at screen .5,.88 center
set key right title "抑制率"
set style data lines
set xlabel "日"
set ylabel "感染率 (%)"
set xrange [:200]
plot for [i=${nf}:1:-1] 'infected' using 1:i+1 \
 title sprintf("%d%%",(11-i)*10)\
 lw 2 lc rgb hsv2rgb((${nf}-i)*.8/${nf},1,.8)
EOF
open $dst