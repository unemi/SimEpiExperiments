#! /bin/bash
tl=258 # August 31
nd=`pwd | awk -F/ '{if($NF ~ /^V.*_[0-9][0-9][0-9]_[0-9][0-9][0-9]$/)print $NF;else print 1}'`
if [ $nd = 1 ]; then echo "This command must run from V?_999_999."; exit; fi
prdList=[0-9][0-9]
for prd in $prdList; do
  for x in infected testPositive; do
    if [ ! -f $prd/$x.csv ]; then echo "$prd/$x.csv does not exit."; exit; fi
  done
done
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/$nd"
if [ ! -d $dst ]; then mkdir -p $dst; fi
popx=`pwd | awk -F/ '{n=substr($(NF-1),length($(NF-1)),1);printf "%d,000\n",n*n*10}'`
ed=22
vd=`echo $nd | awk -F_ '{print $3}'`
rds=`echo $nd | awk -F_ '{print $2}'`
rd=`echo $rds | awk '{printf "%d\n",$1}'`
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
cmfi=../R_${rds}_167/infected_$rd.csv
cmft=../R_${rds}_167/testPositive_$rd.csv
awk '$1<='$vd'{print}' 02/infected.csv > in_c.csv
awk '$1<='$vd'{print}' 02/testPositive.csv > tp_c.csv
for pr in $prdList; do
  awk '$1>='$vd'{print}' $pr/infected.csv > in_$pr.csv
  awk '$1>='$vd'{print}' $pr/testPositive.csv > tp_$pr.csv
done
for gfx in {1..4}; do
gfm=`echo ${gfx} 4 5 6 8 | awk '{printf "%02d\n",$($1+1)}'`
gfnx=`echo ${gfx} 4 5 6 8 | awk '{printf "%d%%\n",$($1+1)}'`
echo plot in_$gfm.svg 
gnuplot > $dst/in_$gfm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${popx}\nGathering frequency = ${gfnx}\n"\
 at screen .5,.85 center
set key right bottom title "Perform rate"
set style data lines
set ylabel "infected (%)"
set xrange [:$tl]
set yrange [:.4]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at $ed,graph .75
set label "→ lifting $rdDate" at $rd,graph .55
set label "→ vaccine" at $vd,graph .45
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .6 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgbcolor "#660099"
plot '$cmfi' using 1:2 notitle lc rgb "#999999",\
  'in_c.csv' using 1:$gfx+1 notitle lc rgb "#999999",\
  'in_02.csv' using 1:$gfx+1 title "0.2%" lc rgb hsv2rgb(0,1,.8),\
  'in_04.csv' using 1:$gfx+1 title "0.4%" lc rgb hsv2rgb(.2,1,.8),\
  'in_06.csv' using 1:$gfx+1 title "0.6%" lc rgb hsv2rgb(.4,1,.8),\
  'in_08.csv' using 1:$gfx+1 title "0.8%" lc rgb hsv2rgb(.8,1,.8)
EOF
echo plot tp_$gfm.svg 
gnuplot > $dst/tp_$gfm.svg <<EOF
set terminal svg size 640 240
set label "Population size = ${popx}\nGathering frequency = ${gfnx}\n"\
 at screen .5,.85 center
set key right bottom title "Perform rate"
set style data lines
set ylabel "test positive (%)"
set xrange [:$tl]
set yrange [:.02]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ emergency declaration" at $ed,graph .75
set label "→ lifting $rdDate" at $rd,graph .55
set label "→ vaccine" at $vd,graph .45
set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .6 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgbcolor "#660099"
plot '$cmft' using 1:2 notitle lc rgb "#999999",\
  'tp_c.csv' using 1:$gfx+1 notitle lc rgb "#999999",\
  'tp_02.csv' using 1:$gfx+1 title "0.2%" lc rgb hsv2rgb(0,1,.8),\
  'tp_04.csv' using 1:$gfx+1 title "0.4%" lc rgb hsv2rgb(.2,1,.8),\
  'tp_06.csv' using 1:$gfx+1 title "0.6%" lc rgb hsv2rgb(.4,1,.8),\
  'tp_08.csv' using 1:$gfx+1 title "0.8%" lc rgb hsv2rgb(.8,1,.8)
EOF
done
rm {in,tp}_{c,0[2468]}.csv
open $dst