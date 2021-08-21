#! /bin/bash
tl=258 # August 31
nd=`pwd | awk -F/ '{print $(NF-1)}'`
gfs=`pwd | awk -F/ '{print $NF}'`
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/$nd/$gfs"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`pwd | awk -F/ '{n=substr($(NF-2),length($(NF-2)),1);printf "%d\n",n*n*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
gf=`echo $gfs | awk '{printf "%d\n",$1}'`
ed=22
vd=`echo $nd | awk -F_ '{print $3}'`
rds=`echo $nd | awk -F_ '{print $2}'`
rd=`echo $rds | awk '{printf "%d\n",$1}'`
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
cmd=$rd
cms=`expr $cmd \* 16`
cmfi=../../R_${rds}_167/infected_$rd.csv
cmft=../../R_${rds}_167/testPositive_$rd.csv
dmax=0
dmaxd=""
if [ -z "$1" ]; then
rm -rf peak2.csv
for d in MyResult_??; do
# goto Ave
cd $d
mm=`echo $d | awk -F_ '{printf "%02d\n",$2+1}'`
prx=`echo $d | awk -F_ '{printf "%.1f%%\n",($2+1)/10}'`
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
echo $prx | awk '{printf "\t\"%s\"\n",$0}' > iAve.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' infected.csv >> iAve.csv
awk '{for(i=2;i<=NF;i++)if(v[i]<$i){v[i]=$i;d[i]=$1-'$vd'}}\
 END{sv=0;sv2=0;sd=0;sd2=0;n=NF-1;\
  for(i=2;i<=NF;i++){sv+=v[i];sv2+=v[i]*v[i];sd+=d[i];sd2+=d[i]*d[i]}\
  Ev=sv/n;Vv=sv2/n-Ev*Ev;Ed=sd/n;Vd=sd2/n-Ed*Ed;\
  printf "%.1f\t%.6f\t%.6f\t%.3f\t%.3f\n",'$mm'/10,Ev,sqrt(Vv),Ed,sqrt(Vd)}'\
 infected.csv >> ../peak2.csv
#
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
echo $prx | awk '{printf "\t\"%s\"\n",$0}' > tAve.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.6f\n",s/(NF-1)}' testPositive.csv >> tAve.csv
#
if [ -z "$1" ]; then
nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot in_$mm.svg 
gnuplot > $dst/in_$mm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${popx}\nGathering frequency = ${gf}%\nperform rate = $prx"\
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
set label "Population size = ${popx}\nGathering frequency = ${gf}%\nperform rate = $prx"\
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
awk 'BEGIN{print "PR"}\
{print $1}' $dmaxd/infected.csv > xx.csv
lam xx.csv MyResult_??/iAve.csv > infected.csv
awk 'NR>1{s=0;for(i=2;i<=NF;i++)if(v[i]<$i){v[i]=$i;d[i]=$1}}\
 END{print "PR\tpeak\tday";for(i=2;i<=NF;i++)printf "%.1f\t%s\t%s\n",(i-1)/10,v[i],d[i]-'$vd'}'\
   infected.csv > peak.csv
awk 'BEGIN{print "PR"}\
{print $1}' $dmaxd/testPositive.csv > xx.csv
lam xx.csv MyResult_??/tAve.csv > testPositive.csv
rm xx.csv
fi
#
nf=`head -1 infected.csv | awk '{print NF}'`

makePlot () {
local cp=""
if [ -z $2 ]; then cp="\
set label \"→ emergency declaration\" at $ed,graph .75
set label \"→ lifting $rdDate\" at $rd,graph .65
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor \"red\"
set arrow from $rd,graph 0 to $rd,graph .7 nohead lc rgbcolor \"#008800\"
"; fi
local pf=$cmfi
local df=infected
if [ $1 == "tp" ]; then
  pf=$cmft
  df=testPositive
fi
echo plot $1$2_A.svg
gnuplot > $dst/$1$2_A.svg <<EOF
set terminal svg size 640 300
set label "Population size = ${popx}\nGathering frequency = ${gf}%" at screen .5,.85 center
set key right title "Perform rate" left
set style data lines
set ylabel "$3 (%)"
set xrange [$2:$tl]
set yrange [:$4]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
$cp
set label "→ vaccine" at $vd,graph .55
set arrow from $vd,graph 0 to $vd,graph .6 nohead lc rgbcolor "#660099"
plot '$pf' using 1:2 notitle lc rgb "#999999",\
  for [i=2:$nf] '$df.csv' using 1:i title columnhead lc rgb hsv2rgb((i-2.)/$nf,1.,.8)
EOF
}
makePlot in "" "infected" .4
makePlot tp "" "test positive" .02
makePlot in 106 "infected" ""
makePlot tp 106 "test positive" ""
#
echo plot peak.svg
gnuplot > $dst/peak.svg <<EOF
set terminal svg size 640 300
set label "Population size = ${popx}\nGathering frequency = ${gf}%" at screen .5,.85 center
set style data boxes
set style fill solid .75
set boxwidth .04
set xlabel "perform rate (% per population day)"
set xrange [.15:1.05]
set xtics nomirror .1 .1
set ylabel "infected (%)"
set ytics nomirror
set y2label "peak days from vaccination"
set y2tics
set yrange [0:]
set y2range [0:]
plot 'peak.csv' using (\$1-.02):2 title "peak infected",\
 '' using (\$1+.02):3 title "peak day" axis x1y2
EOF
#
echo plot peak2.svg
gnuplot > $dst/peak2.svg <<EOF
set terminal svg size 640 300
set label "Population size = ${popx}\nGathering frequency = ${gf}%" at screen .5,.85 center
set style data boxerrorbars
set style fill solid .75
set boxwidth .04
set xlabel "perform rate (% per population day)"
set xrange [.15:1.05]
set xtics nomirror .1 .1
set ylabel "infected (%)"
set ytics nomirror
set y2label "peak days from vaccination"
set y2tics
set yrange [0:]
set y2range [0:]
plot 'peak2.csv' using (\$1-.02):2:3 title "peak infected",\
 '' using (\$1+.02):4:5 title "peak day" axis x1y2
EOF
open $dst