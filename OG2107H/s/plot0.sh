#! /bin/bash
pp=10
pop=$((pp*pp*100))
ed=22 # emergency declaration day (January 7)
tl=0
for f in MyResult_??/daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $nn ]; then tl=$nn; fi
done
# goto TPAV
echo '"day"' > X1.csv
for ((x=1;x<=$tl;x++)); do echo $x >> X1.csv; done
cp X1.csv X2.csv
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
rm XX.csv; touch XX.csv
n=0
for f in indexes_*.csv; do
  awk -F, '$1>0 && ($1%12)==0{printf "%d\t\n",$7+$8}' $f > A$n.csv
  if [ $n -eq 7 ]; then n=0; lam XX.csv A[0-7].csv > X2.csv; mv X2.csv XX.csv
  else n=$((n+1)); fi
done
if [ $n -gt 0 ]; then lam XX.csv A[0-$((n-1))].csv > X2.csv; mv X2.csv XX.csv; fi
rm A[0-7].csv
echo $d | awk -F_ '{printf "\t\"QE%d\"\t\"QM%d\"\n",$2,$2}' > B.csv
gawk '{s=0;for(i=1;i<=NF;i++){s+=$i;v[i]=$i}asort(v);\
printf "\t%.8f\t%.8f\n",s/NF/'$pop'/10,((NF%2==1)?v[(NF+1)/2]:(v[NF/2]+v[NF/2+1])/2)/'$pop'/10}'\
 XX.csv >> B.csv
rm XX.csv
cd ..
done
lam X1.csv MyResult_??/A.csv > testPositive.csv
lam X2.csv MyResult_??/B.csv > quarantine.csv
rm X[12].csv MyResult_??/{A,B}.csv
nf=`head -1 testPositive.csv | awk '{print NF}'`
yr=`awk 'BEGIN{H=.025;L=.004}\
$1>0{for(i=2;i<=NF;i++){if(H<$i)H=$i;if(L>$i)L=$i}}\
END{printf "[%.8f:%.8f]\n",L,H}' testPositive.csv` 
#
cat > /tmp/gp$$ <<EOF
set terminal svg size 640 300
set key right
set style data lines
set ylabel "test positive (%)"
set xrange [1:${tl}]
set label "population size = `expr $pop / 10`,000" at screen .5,.88 center
set label "??? emergency declaration" at $ed,graph .1
set arrow from $ed,graph 0 to $ed,graph .9 nohead lc rgb "#884400"
EOF
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
echo plot $1$2.svg
cat /tmp/gp$$ - <<EOF | gnuplot > $1$2.svg
if ("$3" eq "date") { set xtics ($xmarks) }
if ("$4" eq "log") { set yrange $yr; set logscale y }
if ("$1" eq "TP") {
set ytics nomirror
set y2tics
set y2range [0:2]
plot for [i=2:$nf] 'testPositive.csv' using 1:i \
 title columnhead lc rgb hsv2rgb((i-2.)/$nf/2.,1,.8),\
 'gatFreq.csv' using 1:2 axis x1y2 lc rgb "#666666",\
 '/Users/unemi/Research/SimEpidemicPJ/?????????PJ/??????????????????/nhk_pref_weekly/13?????????.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2 }
else {
plot for [i=2:$nf] 'quarantine.csv' using 1:i \
 title columnhead lc rgb hsv2rgb((i+$nf-2.)/$nf/2.,1,.8),\
 '/Users/unemi/Research/SimEpidemicPJ/?????????PJ/??????????????????/tky_patients.csv'\
  using 0:((\$3+\$4+\$5+\$6+\$7) / 139600.0 * 0.1) title "Quarantine" lc rgb "#004400" }
EOF
}
if [ ! -f gatFreq.csv ]; then echo "0 0" > gatFreq.csv; fi
makePlot TP Average date linear
makePlot TP AverageDay day linear
makePlot TP AverageLog day log
# makePlot Q Average date linear
# makePlot Q AverageDay day linear
# makePlot Q AverageLog day log
rm /tmp/gp$$
#
# cat /Users/unemi/Research/SimEpidemicPJ/?????????PJ/??????????????????/nhk_pref_weekly/13?????????.csv \
#  testPositive.csv | awk '{if($1==NR-1){if($1>=316)t[++n]=$2/1396}\
#  else if($1~/day/)for(i=2;i<=NF;i++)nm[i]=$i;\
#  else if($1>='$ed' && $1<=n)for(i=2;i<=NF;i++){d=t[$1-'$ed']-$i*100;e[i]+=d*d}}\
# END{for(i=2;i<=NF;i++)printf "%s %.5f\n",nm[i],e[i]/n}' > plotResult.txt
# cat plotResult.txt
