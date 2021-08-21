#! /bin/bash
popN=`pwd | awk -F/ '{d=$(NF-1);print substr(d,length(d),1)}'`
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/VPF_$popN/NoVcn"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`echo $popN | awk '{print $1*$1*100}'`
spd=12
ed=22
ld=`expr $ed + 73`
vd=`expr $ed + 94`
n=0
for f in MyResult_??/indexes_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi
done
lds=`expr $ld \* $spd`
tl=`expr $n / $spd`
awk -F, '$1>=1 && $1<='$lds'{s+=$2+$3;n++;\
if($1%'$spd'==0){printf "%d\t%.6f\n",$1/'$spd',s/n/'$pop';s=0;n=0}}'\
  MyResult_00/indexes_1.csv > inToLD.csv
echo '"day"' > X.csv
for ((x=$ld;x<=$tl;x++)); do echo $x >> X.csv; done
for d in MyResult_??; do
cd $d
ns=`echo indexes_*.csv | awk '{print NF}'`
rm -f XX.csv
touch XX.csv
for f in indexes_*.csv; do
  awk -F, '$1>='$lds'-'$spd'+1{s+=$2+$3;n++;if($1%'$spd'==0){printf "\t%.6f\n",s/n;s=0;n=0}}'\
   $f > A.csv
  lam XX.csv A.csv > X2.csv
  mv X2.csv XX.csv
done
echo $d | awk -F_ '{printf "\t\"x%.1f\"\n",$2/2+1}' > A.csv
awk '{s=0;for(i=1;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/'$ns'/'$pop'}' XX.csv >> A.csv
rm XX.csv
cd ..
done
lam X.csv MyResult_??/A.csv > infected.csv
rm X.csv MyResult_??/A.csv
nf=`head -1 infected.csv | awk '{print NF}'`
#
echo plot INAverage.svg
gnuplot <<EOF > $dst/INAverage.svg
set terminal svg size 640 300
set key right title "Gathering frequency"
set style data lines
set ylabel "infected (%)"
set xrange [1:${tl}]
set yrange [:.3]
set label "population size = `expr $pop / 10`,000" at screen .5,.88 center
set label "→ emergency declaration" at $ed,graph .78
set label "→ lift declaration" at $ld,graph .3
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgb "red"
set arrow from $ld,graph 0 to $ld,graph .4 nohead lc rgb "#008800"
set xtics ("Jan 7" $ed, "Feb 7" $ed+31, "Mar 7" $ed+59, "Apr 1" $ed+84, "May 1" $ed+114,\
 "Jun 1" $ed+145, "Jul 1" $ed+175, "Aug 1" $ed+206)
plot for [i=$nf:2:-1] 'infected.csv' using 1:i \
 title columnhead lc rgb hsv2rgb(($nf-i)/($nf-1.),1,.8),\
 'inToLD.csv' using 1:2 notitle lc rgb "#999999"
EOF
open $dst