#! /bin/bash
nd=`pwd | awk -F/ '{print $NF}'`
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/$nd"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`pwd | awk -F/ '{n=substr($(NF-2),length($(NF-2)),1);printf "%d\n",n*n*100}'`
vd=`echo $nd | awk -F_ '{print $3}'`
tl=$vd
rds=`echo $nd | awk -F_ '{print substr($2,2,3)}'`
rd=`echo $rds | awk '{printf "%d\n",$1}'`
cmd=$rd
cms=`expr $cmd \* 16`
awk -F, '$1>0 && $1<='$cms'{x+=$2+$3;n++;\
  if($1%4==0){printf "%.2f\t%.6f\n",$1/16,x/n/'$pop'.;x=0;n=0}}'\
  MyResult_00/indexes_1.csv > infected_$cmd.csv
awk -F, '$1>0 && $1<='$cmd'{printf "%d\t%.8f\n",$1,$2/'$pop'}'\
  MyResult_00/daily_1.csv > testPositive_$cmd.csv
for d in MyResult_??; do
# goto Ave
cd $d
mm=`echo $d | awk -F_ '{printf "%02d\n",$2*5+5}'`
nx=`echo $d | awk -F_ '{printf "%d%%\n",$2*5+5}'`
n=0;s=0
for f in indexes_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi
  nn=`head -2 $f | tail -1 | cut -d, -f1`
  if [ $s -lt $nn ]; then s=$nn; fi
done
touch XX.csv
for f in `ls indexes_*.csv | sort -t_ -k2 -n`; do
  awk -F, '$1>='$cms'{x+=$2+$3;n++;if($1%'$s'==0){printf "\t%.6f\n",x/n/'$pop'.;x=0;n=0}}'\
   $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/'$s';i<$1/'$s';i++) print "\t0"}' >> X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
done
awk '{printf "%.2f%s\n",(NR-1)*'$s'/16+'$cmd',$0}' XX.csv > infected.csv
rm XX.csv
echo $nx | awk '{printf "\t\"%s\"\n",$0}' > iAve.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' infected.csv >> iAve.csv
#
nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot in_$mm.svg 
gnuplot > $dst/in_$mm.svg <<EOF
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
plot '../infected_$cmd.csv' using 1:2 notitle lc rgb "#999999",\
  for [i=2:(${nf}+1)] 'infected.csv' using 1:i
EOF
#
n=0
for f in daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi 
done
touch XX.csv
for f in `ls daily_*.csv | sort -t_ -k2 -n`; do
  awk -F, '$1>='$cmd'{printf "\t%.8f\n",$2/'$pop'}\
  END{for(i=NR;i<='$n';i++) print "\t0"}' $f > X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
done
awk '{printf "%d%s\n",NR+'$cmd'-1,$0}' XX.csv > testPositive.csv
rm XX.csv
echo $nx | awk '{printf "\t\"%s\"\n",$0}' > tAve.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' testPositive.csv >> tAve.csv
echo plot tp_$mm.svg 
gnuplot > $dst/tp_$mm.svg <<EOF
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
plot '../testPositive_$cmd.csv' using 1:2 notitle lc rgb "#999999",\
  for [i=2:(${nf}+1)] 'testPositive.csv' using 1:i
EOF
cd ..
done
#
awk 'BEGIN{print "GF"}\
{print $1}' MyResult_00/infected.csv > xx.csv
lam xx.csv MyResult_??/iAve.csv > infected.csv
nf=`head -1 infected.csv | wc -w`
echo plot in_A.svg
gnuplot > in_A.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
set key right bottom title "Gathering frequency" left
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.4]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .75
set label "→ lifting declaration" at $rd,graph .75
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .8 nohead lc rgbcolor "#008800"
plot 'infected_$cmd.csv' using 1:2 notitle lc rgb "#999999",\
  for [i=${nf}:2:-1] 'infected.csv' using 1:i title columnhead
EOF
#
awk 'BEGIN{print "GF"}\
{print $1}' MyResult_00/testPositive.csv > xx.csv
lam xx.csv MyResult_??/tAve.csv > testPositive.csv
rm xx.csv
nf=`head -1 infected.csv | wc -w`
echo plot tp_A.svg
gnuplot > tp_A.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${pop}00" at screen .5,.85 center
set key right bottom title "Gathering frequency" left
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.02]
set xtics ("Dec 24" 8, "Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197)
set label "→ emergency declaration" at 22,graph .75
set label "→ lifting declaration" at $rd,graph .75
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .8 nohead lc rgbcolor "#008800"
plot 'testPositive_$cmd.csv' using 1:2 notitle lc rgb "#999999",\
  for [i=${nf}:2:-1] 'testPositive.csv' using 1:i title columnhead
EOF
#
open $dst