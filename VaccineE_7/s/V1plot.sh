#! /bin/bash
# If any argument exist, this command does not make SVG but only CSV
#
tl=258 # August 31
nd=`pwd | awk -F/ '{d=$(NF-1);print (d~/^V_[03]_[0-9][0-9][0-9]/)?d:1}'`
prs=`pwd | awk -F/ '{print $NF}'`
if [ $nd = 1 ]; then echo "This script must run from V_?_???/??."; exit; fi
vd=`echo $nd | awk -F_ '{print $3}'`
vp=`echo $nd | awk -F_ '{print $2}'`
va=`echo $nd | awk -F_ '{print (NF>3)?$4:0}'`
ds=`echo $nd | cut -c3-`
popN=`pwd | awk -F/ '{print substr($(NF-2),length($(NF-2)),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
pr=`pwd | awk -F/ '{printf "%d\n",$NF}'`
ed=22
rds="095"
rd=`echo $rds | awk '{printf "%d\n",$1}'`
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
cmd=$rd
cms=`expr $cmd \* 16`
cmfi=../../NoVcn/inToLD.csv
cmft=../../NoVcn/tpToLD.csv
dmax=0
dmaxd=""
for d in MyResult_??; do
# goto Ave
cd $d
x=`echo $d | awk -F_ '{printf "%d\n",$2}'`
mm=`echo $x | awk '{print $1+1}'`
nx=`printf "%d%%" $mm`
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
n=0
for f in daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi 
done
if [ $dmax -lt $n ]; then dmax=$n; dmaxd=$d; fi
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
#
if [ "$1" == "" ]; then
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/VPE_$popN/$ds/$prs"
if [ ! -d $dst ]; then mkdir -p $dst; fi
nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot in_$mm.svg 
gnuplot > $dst/in_$mm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${popx}\nGathering frequency = ${nx}\nperform rate = 0.${pr}%"\
 at screen .5,.85 center
unset key
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.4]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at $ed,graph .65
set label "→ lifting $rdDate" at $rd,graph .55
set label "→ vaccine" at $vd,graph .45
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .6 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgbcolor "#660099"
plot '../$cmfi' using 1:2 notitle lc rgb "#999999",\
  for [i=2:(${nf}+1)] 'infected.csv' using 1:i
EOF
echo plot tp_$mm.svg 
gnuplot > $dst/tp_$mm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${popx}\nGathering frequency = ${nx}\nperform rate = 0.${pr}%"\
 at screen .5,.85 center
unset key
set style data lines
set ylabel "test positive (%)"
set xrange [:$tl]
set yrange [:.02]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at $ed,graph .65
set label "→ lifting $rdDate" at $rd,graph .55
set label "→ vaccine" at $vd,graph .45
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .6 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgbcolor "#660099"
plot '../$cmft' using 1:2 notitle lc rgb "#999999",\
  for [i=2:(${nf}+1)] 'testPositive.csv' using 1:i
EOF
fi
cd ..
done
#
lmaxi=`awk 'END{print NR}' $dmaxd/iAve.csv`
lmaxt=`awk 'END{print NR}' $dmaxd/tAve.csv`
for d in MyResult_??; do
  for ((x=`awk 'END{print NR}' $d/iAve.csv`;x<$lmaxi;x++)); do
    echo "  0" >> $d/iAve.csv
  done
  for ((x=`awk 'END{print NR}' $d/tAve.csv`;x<$lmaxt;x++)); do
    echo "  0" >> $d/tAve.csv
  done
done
awk 'BEGIN{print "GF"}\
{print $1}' $dmaxd/infected.csv > xx.csv
lam xx.csv MyResult_??/iAve.csv > infected.csv
#
awk 'BEGIN{print "GF"}\
{print $1}' $dmaxd/testPositive.csv > xx.csv
lam xx.csv MyResult_??/tAve.csv > testPositive.csv
rm xx.csv
#
if [ "$1" == "" ]; then
nf=`head -1 infected.csv | wc -w`
echo plot in_A.svg
gnuplot > $dst/in_A.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${popx}\nPerform rate = 0.${pr}%" at screen .5,.85 center
set key right bottom title "Gathering frequency" left
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.4]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at $ed,graph .75
set label "→ lifting $rdDate" at $rd,graph .65
set label "→ vaccine" at $vd,graph .55
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .7 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .6 nohead lc rgbcolor "#660099"
plot '$cmfi' using 1:2 notitle lc rgb "#999999",\
  for [i=${nf}:2:-1] 'infected.csv' using 1:i title columnhead
EOF
#
nf=`head -1 infected.csv | wc -w`
echo plot tp_A.svg
gnuplot > $dst/tp_A.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${popx}\nPerform rate = 0.${pr}%" at screen .5,.85 center
set key right bottom title "Gathering frequency" left
set style data lines
set ylabel "test positive (%)"
set xrange [:$tl]
set yrange [:.02]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at $ed,graph .75
set label "→ lifting $rdDate" at $rd,graph .65
set label "→ vaccine" at $vd,graph .55
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .7 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .6 nohead lc rgbcolor "#660099"
plot '$cmft' using 1:2 notitle lc rgb "#999999",\
  for [i=${nf}:2:-1] 'testPositive.csv' using 1:i title columnhead
EOF
#
open $dst
fi