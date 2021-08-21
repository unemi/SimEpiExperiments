#! /bin/bash
# plot the time series of asymptomatic patient in town.
dtDir="MyResult_00"
tl=0
for f in $dtDir/daily_*.csv; do
  n=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $n ]; then tl=$n; fi
done
#
awk -F, 'BEGIN{tl='$tl';for(i=1;i<=tl;i++)v[d]=v2[d]=n[d]=0}\
FNR>1 && $1%12==0{d=$1/12;x=$2-$7;v[d]+=x;v2[d]+=x*x;n[d]++}\
END{for(d=1;d<=tl;d++)printf "%.8f %.8f\n",\
 v[d]/n[d]/10000,sqrt((v2[d]-v[d]*v[d]/n[d])/n[d])/10000}'\
 $dtDir/indexes_*.csv > AP.csv
#
LANG=C
tspan=$(((tl-1)/10))
declare -a arr
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
#
makePlot () {
gnuplot > AP-$1.svg <<EOF
set terminal svg size 720 300
set key left
set ylabel "asymptomatic patients in community (%)"
set style data lines
set xtics ($xmarks)
if ("$1" eq "log") { set logscale y } 
plot 'AP.csv' using 0:1 title "Average" lc "#880000" lw 2,\
 '' using 0:(\$1 + \$2) title "μ ± σ" lc "#cc2222" dt 2,\
 '' using 0:(\$1 - \$2) notitle lc "#cc2222" dt 2
EOF
}
makePlot linear
makePlot log