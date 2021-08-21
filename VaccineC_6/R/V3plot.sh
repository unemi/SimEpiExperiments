#! /bin/bash
tl=258 # August 31
nd=`pwd | awk -F/ '{if($NF ~ /^V.*_[0-9][0-9][0-9]_[0-9][0-9][0-9]$/)print $NF;else print 1}'`
if [ $nd = 1 ]; then echo "This command must run from V?_999_999."; exit; fi
prdList=`echo [0-9][0-9]`
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
nprd=`echo $prdList | awk '{print NF}'`
for gfx in 1 2 3; do
gfm=`echo ${gfx} | awk '{printf "%02d\n",$1+3}'`
gfnx=`echo ${gfx} | awk '{printf "%d%%\n",$1+3}'`
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
array pr[$nprd] = [ `echo $prdList | awk '{for(i=1;i<=NF;i++)printf "\"%s\",",$i}'` ]
plot '$cmfi' using 1:2 notitle lc rgb "#999999",\
  'in_c.csv' using 1:$gfx+1 notitle lc rgb "#999999",\
  for [i=1:$nprd] sprintf("in_%s.csv",pr[i]) using 1:$gfx+1\
   title sprintf("%.1f%",pr[i]/10.) lc rgb hsv2rgb((i-1.)/$nprd,1.,.667)
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
array pr[$nprd] = [ `echo $prdList | awk '{for(i=1;i<=NF;i++)printf "\"%s\",",$i}'` ]
plot '$cmft' using 1:2 notitle lc rgb "#999999",\
  'tp_c.csv' using 1:$gfx+1 notitle lc rgb "#999999",\
  for [i=1:$nprd] sprintf("tp_%s.csv",pr[i]) using 1:$gfx+1\
   title sprintf("%.1f%",pr[i]/10.) lc rgb hsv2rgb((i-1.)/$nprd,1.,.667)
EOF
done
rm {in,tp}_{c,[0-9][0-9]}.csv
open $dst