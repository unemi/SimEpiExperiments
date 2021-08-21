#! /bin/bash
pp=`pwd | awk -F/ '{print substr($NF,2,1)}'`
pop=$((pp*pp*100))
ed=22 # emergency declaration day (January 7)
rd=95 # lifting day (March 21)
md=117 # Apr 12, stricter measures
ed2=131 # Apr 26, 3rd emergency declaration
rd2=166 # May 31, lifting 3rd declaration
tl=0
for f in MyResult_??/daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $nn ]; then tl=$nn; fi
done
# goto TPAV
echo '"day"' > X.csv
for ((x=1;x<=$tl;x++)); do echo $x >> X.csv; done
for d in MyResult_??; do
cd $d
rm -f XX.csv
touch XX.csv
m=0;n=0
for f in daily_*.csv; do
  awk -F, 'BEGIN{s=0;i=0;n=0;for(j=0;j<7;j++)v[j]=0}\
  $1>0{s+=$2-v[i];v[i]=$2;i=(i+1)%7;if(n<7)n++;if(n>3)printf "%.4f\t\n",s/n}\
  END{for(j=0;j<3;j++){s-=v[i];i=(i+1)%7;n--;printf "%.4f\t\n",s/n}}' $f > A$n.csv
  if [ $n -eq 7 ]; then n=0; lam XX.csv A[0-7].csv > X2.csv; mv X2.csv XX.csv
  else n=$((n+1)); fi
  m=$((m+1))
  if [ $m -ge 120 ]; then break; fi
done
if [ $n -gt 0 ]; then lam XX.csv A[0-$((n-1))].csv > X2.csv; mv X2.csv XX.csv; fi
rm A[0-7].csv
echo $d | awk -F_ '{printf "\t\"E%d\"\t\"M%d\"\n",$2,$2}' > A.csv
gawk '{s=0;for(i=1;i<=NF;i++){s+=$i;v[i]=$i}asort(v);\
printf "\t%.8f\t%.8f\n",s/NF/'$pop',((NF%2==1)?v[(NF+1)/2]:(v[NF/2]+v[NF/2+1])/2)/'$pop'}'\
 XX.csv >> A.csv
rm XX.csv
cd ..
done
lam X.csv MyResult_??/A.csv > testPositive.csv
rm X.csv MyResult_??/A.csv
nf=`head -1 testPositive.csv | awk '{print NF}'`
#
makePlot () {
if [ "$2" = "date" ]; then
declare -a arr
LANG=C
local tspan=$(((tl-1)/5))
for ((x=0;x<5;x++)); do local d=$((x*tspan+tspan/2+1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
fi
#
echo plot $1.svg
gnuplot <<EOF > $1_$st.svg
set terminal svg size 640 300
set key right
set style data lines
set ylabel "test positive (%)"
set xrange [${st}:${tl}]
set label "population size = `expr $pop / 10`,000" at screen .5,.88 center
set label "→ emergency declaration" at $ed,graph .1
set label "→ lift declaration" at $rd,graph .7
set label "→ stricter measures" at $md,graph .18
set label "→ emergency declaration" at $ed2,graph .1
set arrow from $ed,graph 0 to $ed,graph .9 nohead lc rgb "#884400"
set arrow from $rd,graph 0 to $rd,graph .9 nohead lc rgb "#004488"
set arrow from $md,graph 0 to $md,graph .9 nohead lc rgb "#996622"
set arrow from $ed2,graph 0 to $ed2,graph .9 nohead lc rgb "#884400"
if ("$2" eq "date") { set xtics ($xmarks) }
if ("$3" eq "log") { set yrange $yr; set logscale y }
plot for [i=2:$nf] 'testPositive.csv' using 1:i \
 title columnhead dt i%2+1 lc rgb hsv2rgb((i/2-1.)/($nf-1)*2,1,.667),\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2
EOF
}
for st in 0 150; do
yr=`awk 'BEGIN{H=.001;L=.004}\
$1>'$st'{for(i=2;i<=NF;i++){if(H<$i)H=$i;if(L>$i)L=$i}}\
END{printf "[%.8f:%.8f]\n",L,H}' testPositive.csv` 
#
makePlot TPAverage date linear
makePlot TPAverageDay day linear
makePlot TPAverageLog day log
done
#
# cat /Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv \
#  testPositive.csv | awk '{if($1==NR-1){if($1>=316)t[++n]=$2/1396}\
#  else if($1~/day/)for(i=2;i<=NF;i++)nm[i]=$i;\
#  else if($1>='$ed' && $1<=n)for(i=2;i<=NF;i++){d=t[$1-'$ed']-$i*100;e[i]+=d*d}}\
# END{for(i=2;i<=NF;i++)printf "%s %.5f\n",nm[i],e[i]/n}' > plotResult.txt
# cat plotResult.txt
