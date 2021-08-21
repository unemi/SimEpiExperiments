#! /bin/bash
if [ "$1" = "" ]; then s=2; else s=$1; fi
pp=10
pop=$((pp*pp*100))
cd MyResult_00
tl=0
for f in severity_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $nn ]; then tl=$nn; fi
done
awk -F, 'BEGIN{for(i=1;i<='$tl';i++)v[i]=v2[i]=n[i]=0}\
$1>0{x=0;for(j=0;j<'$s';j++)x+=$(NF-j);v[$1]+=x;v2[$1]=x*x}\
END{for(d=1;d<='$tl';d++)\
 printf "%.4f %.4f\n",v[d]/n[d],sqrt((v2[d]-v[d]*v[d]/n[d])/n[d])}'\
 severity_*.csv > ../SV.csv
cd ..
#
declare -a arr
LANG=C
tspan=$((tl/10))
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2))
  arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
#
makePlot () {
echo plot SV$1.svg
gnuplot > SV$1.svg <<EOF
set terminal svg size 640 300
set key right
set style data lines
set xrange [1:${tl}]
if ("$1" eq "date") { set xtics ($xmarks) }
set ylabel "severe patients (%)"
plot 'SV.csv' using 0:(\$1 / 30000.) title "Simulated" lc rgb "#880000",\
  '' using 0:((\$1 + \$2) / 30000.) title "μ ± σ" lc rgb "#cc4444" dt 2,\
  '' using 0:((\$1 - \$2) / 30000.) notitle lc rgb "#cc4444" dt 2,\
  '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/tky_patients.csv'\
  using 0:(\$4 / 139600.) title "Tokyo" lc rgb "#006600"
EOF
}
makePlot date
makePlot day
# for [i=1:10] 'SV.csv' using 0:i title sprintf("%d",i) lc rgb hsv2rgb((i-1)/10.,1,.8),
#    using 0:((\$4+\$3) / 13.96) title "Hospital" lc rgb "#666600" lw 2, ''\
#
# gnuplot > SVX.svg <<EOF
# set terminal svg size 640 300
# set key right
# set style data lines
# set xrange [1:${tl}]
# set ylabel "severe patients (%)"
# plot 'SV.csv' using 0:1 title "Simulated" lc rgb "black" lw 2,\
#   for [i=1:10] '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/tky_patients.csv'\
#   using 0:(\$4 / 13.96 * i) title sprintf("x %d",i) lc rgb hsv2rgb((i-1)/10.,1,.8)
# EOF