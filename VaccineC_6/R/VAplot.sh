#! /bin/bash
tl=258 # August 31
nd=`pwd | awk -F/ '{if($NF ~ /^V_[0-9][0-9][0-9]_[0-9][0-9][0-9]$/)print $NF;else print 1}'`
if [ $nd = 1 ]; then echo "This command must run from V_999_999."; exit; fi
vd=`echo $nd | awk -F_ '{print $3}'`
rds=`echo $nd | awk -F_ '{print $2}'`
rd=`echo $rds | awk '{printf "%d\n",$1}'`
if [ ! -d ../V1_${rds}_$vd ]; then echo "../V1_${rds}_$vd does not exist."; exit; fi
if [ ! -d ../V2_${rds}_$vd ]; then echo "../V2_${rds}_$vd does not exist."; exit; fi
cd ../V2_${rds}_$vd
prdList=`echo [0-9][0-9]`
for prd in $prdList; do
  for x in infected testPositive; do
    if [ ! -f $prd/$x.csv ]; then echo "V2_${rds}_$vd/$prd/$x.csv does not exit."; exit; fi
  done
done
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/$nd"
if [ ! -d $dst ]; then mkdir -p $dst; fi
popx=`pwd | awk -F/ '{n=substr($(NF-1),length($(NF-1)),1);printf "%d,000\n",n*n*10}'`
ed=22
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
#
cd ../V_${rds}_$vd
awk '$1<='$vd'{print}' 02/infected.csv > in_c.csv
awk '$1<='$vd'{print}' 02/testPositive.csv > tp_c.csv
makeCSV () {
  for pr in $prdList; do
    awk '$1>='$vd'{print}' $pr/infected.csv > in_$pr.csv
    awk '$1>='$vd'{print}' $pr/testPositive.csv > tp_$pr.csv
  done
}
makeCSV
cd ../V1_${rds}_$vd
makeCSV
cd ../V2_${rds}_$vd
makeCSV
cd ..
#
nprd=`echo $prdList | awk '{print NF}'`
for gfx in 4 5 6; do
gfm=`echo $gfx | awk '{printf "%02d\n",$1}'`
gfnx=`echo $gfx | awk '{printf "%d%%\n",$1}'`
#
# cmfi=R_${rds}_167/infected_$rd.csv
# cmft=R_${rds}_167/testPositive_$rd.csv
makePlot () {
echo plot $1A${ts}_$gfm.svg 
gnuplot > $dst/$1A${ts}_$gfm.svg <<EOF
set terminal svg size 640 300
set label "Population size = ${popx}\nGathering frequency = ${gfnx}\n"\
 at screen .5,.85 center
set key right title "Perform rate"
set style data lines
set ylabel "$3 (%)"
set xrange [$ts:$tl]
set yrange [:$4]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
if (1$ts==1) {
  set label "→ emergency declaration" at $ed,graph .75
  set arrow from $ed,graph 0 to $ed,graph 1 nohead lc rgbcolor "red"
  set label "→ lifting $rdDate" at $rd,graph .55
  set arrow from $rd,graph 0 to $rd,graph .6 nohead lc rgbcolor "#008800"
}
set label "→ vaccine" at $vd,graph .45
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgbcolor "#660099"
array pr[$nprd] = [ `echo $prdList | awk '{for(i=1;i<=NF;i++)printf "\"%s\",",$i}'` ]
array cl[$nprd]
do for [i=1:$nprd] { cl[i] = hsv2rgb((i-1.)/$nprd,1.,.667) }
plot 'R_${rds}_167/$2_$rd.csv' using 1:2 notitle lc rgb "#999999",\
  'V_${rds}_$vd/$1_c.csv' using 1:$gfx-2 notitle lc rgb "#999999",\
  for [i=1:$nprd] sprintf("V_${rds}_$vd/$1_%s.csv",pr[i]) using 1:$gfx-2\
   notitle dt 2 lc rgb cl[i],\
  for [i=1:$nprd] sprintf("V1_${rds}_$vd/$1_%s.csv",pr[i]) using 1:$gfx-2\
   title sprintf("%.1f%",pr[i]/10.) dt 1 lc rgb cl[i],\
  for [i=1:$nprd] sprintf("V2_${rds}_$vd/$1_%s.csv",pr[i]) using 1:$gfx-2\
   notitle dt 3 lc rgb cl[i]
EOF
}
#
ts=""
makePlot in infected "infected" .4
makePlot tp testPositive "test positive" .02
ts=106
makePlot in infected "infected" ""
makePlot tp testPositive "test positive" ""
done
rm V*_???_???/{in,tp}_{c,[0-9][0-9]}.csv
open $dst