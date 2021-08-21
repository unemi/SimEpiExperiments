#! /bin/bash
nd=`pwd | awk -F/ '{print $NF}'`
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/$nd"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`pwd | awk -F/ '{n=substr($(NF-1),length($(NF-1)),1);printf "%d\n",n*n*100}'`
vd=`echo $nd | awk -F_ '{print $3}'`
tl=$vd
rds=`echo $nd | awk -F_ '{print substr($2,2,3)}'`
rd=`echo $rds | awk '{printf "%d\n",$1}'`
for d in MyResult_??; do
# goto Ave
cd $d
mm=`echo $d | awk -F_ '{printf "%02d\n",($2+2)*10}'`
nx=`echo $d | awk -F_ '{printf "%.1f%%\n",$2+2}'`
n=0;s=0
for f in indexes_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi
  nn=`head -2 $f | tail -1 | cut -d, -f1`
  if [ $s -lt $nn ]; then s=$nn; fi
done
touch XX.csv
for f in `ls indexes_*.csv | sort -t_ -k2 -n`; do
  awk -F, '$1>0{x+=$2+$3;n++;if($1%'$s'==0){printf "\t%.6f\n",x/n/'$pop'.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/'$s';i<$1/'$s';i++) print "\t0"}' >> X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
done
awk '{printf "%.2f%s\n",NR*'$s'/16,$0}' XX.csv > infected.csv
rm XX.csv
echo $nx | awk '{printf "\t\"%s\"\n",$0}' > iAve.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' infected.csv >> iAve.csv
#
nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot I_$mm.svg 
gnuplot > $dst/I_$mm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00\nGathering frequency = ${nx}" at screen .5,.85 center
unset key
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.4]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .1
set label "→ lifting declaration" at $rd,graph .5
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .7 nohead lc rgbcolor "#008800"
plot for [i=2:(${nf}+1)] 'infected.csv' using 1:i
EOF
#
n=0
for f in daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi 
done
touch XX.csv
for f in `ls daily_*.csv | sort -t_ -k2 -n`; do
  awk -F, '$1>0{printf "\t%.6f\n",$2/'$pop'}\
  END{for(i=NR;i<='$n';i++) print "\t0"}' $f > X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
done
awk '{printf "%d%s\n",NR,$0}' XX.csv > testPositive.csv
rm XX.csv
echo $nx | awk '{printf "\t\"%s\"\n",$0}' > tAve.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' testPositive.csv >> tAve.csv
echo plot T_$mm.svg 
gnuplot > $dst/T_$mm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00\nGathering frequency = ${nx}" at screen .5,.85 center
unset key
set style data lines
set ylabel "test positive (%)"
set xrange [:$tl]
set yrange [:.02]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .1
set label "→ lifting declaration" at $rd,graph .5
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .7 nohead lc rgbcolor "#008800"
plot for [i=2:(${nf}+1)] 'testPositive.csv' using 1:i
EOF
cd ..
done
#
awk 'BEGIN{print "GF"}\
{print $1}' MyResult_00/infected.csv > xx.csv
lam xx.csv MyResult_??/iAve.csv > infected.csv
nf=`head -1 infected.csv | wc -w`
echo plot I_A.svg
gnuplot > $dst/I_A.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
set key right bottom title "Gathering frequency" left
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.4]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .1
set label "→ lifting declaration" at $rd,graph .5
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .8 nohead lc rgbcolor "#008800"
plot for [i=2:${nf}] 'infected.csv' using 1:i title columnhead
EOF
#
awk 'BEGIN{print "GF"}\
{print $1}' MyResult_00/testPositive.csv > xx.csv
lam xx.csv MyResult_??/tAve.csv > testPositive.csv
rm xx.csv
nf=`head -1 infected.csv | wc -w`
echo plot T_A.svg
gnuplot > $dst/T_A.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
set key right bottom title "Gathering frequency" left
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.02]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .1
set label "→ lifting declaration" at $rd,graph .5
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .8 nohead lc rgbcolor "#008800"
plot for [i=2:${nf}] 'testPositive.csv' using 1:i title columnhead
EOF
#
open $dst