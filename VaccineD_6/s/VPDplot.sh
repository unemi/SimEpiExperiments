#! /bin/bash
tl=258 # August 31
nd=`pwd | awk -F/ '{if($NF ~ /^V_[0-9]_[0-9][0-9][0-9]$/)print $NF;else print 1}'`
if [ $nd = 1 ]; then echo "This command must run from V_9_999."; exit; fi
vd=`echo $nd | awk -F_ '{print $3}'`
vp=`echo $nd | awk -F_ '{print $2}'`
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
rds="095"
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/VPD_$popN/$vd"
if [ ! -d $dst ]; then mkdir -p $dst; fi
rd=`echo $rds | awk '{printf "%d\n",$1}'`
popx=`echo $popN | awk '{printf "%d0,000\n",$1*$1}'`
ed=22
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
#
makeCSV () {
  for pr in $prdList; do
    awk '$1>='$vd'{print}' $pr/infected.csv > in_$pr.csv
    awk '$1>='$vd'{print}' $pr/testPositive.csv > tp_$pr.csv
  done
}
#
makePlot () {
echo plot $1PD${ts}_$gfm.svg 
gnuplot > $dst/$1PD${ts}_$gfm.svg <<EOF
set terminal svg size 640 300
set label "Population size = ${popx}\nGathering frequency = ${gfnx}\n"\
 at screen .5,.85 center
set key right title "Perform rate"
set style data lines
set ylabel "$2 (%)"
set xrange [$ts:$tl]
set yrange [:$3]
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
plot 'D${rds}_167/$1ToLD.csv' using 1:2 notitle lc rgb "#999999",\
  'V_3_$vd/$1_c.csv' using 1:$gfx+1 notitle lc rgb "#999999",\
  for [i=1:$nprd] sprintf("V_3_$vd/$1_%s.csv",pr[i]) using 1:$gfx+1\
   title sprintf("%.1f%",pr[i]/10.) dt 1 lc rgb cl[i],\
  for [i=1:$nprd] sprintf("V_0_$vd/$1_%s.csv",pr[i]) using 1:$gfx+1\
   notitle dt 2 lc rgb cl[i]
EOF
#   for [i=1:$nprd] sprintf("VSD30_${rds}_$vd/$1_%s.csv",pr[i]) using 1:$gfx+1\
#    notitle dt 4 lc rgb cl[i]
}
#
cd ..
for vp in 0 3; do
if [ ! -d V_${vp}_$vd ]; then echo "../V_${vp}_$vd does not exist."; exit; fi
cd V_${vp}_$vd
prdList=`echo [0-9][0-9]`
for prd in $prdList; do
  for x in infected testPositive; do
    if [ ! -f $prd/$x.csv ]; then echo "V_${vp}_$vd/$prd/$x.csv does not exit."; exit; fi
  done
  makeCSV
done
cd ..
done
cd V_3_$vd
awk '$1<='$vd'{print}' 02/infected.csv > in_c.csv
awk '$1<='$vd'{print}' 02/testPositive.csv > tp_c.csv
makeCSV
cd ..
#
nprd=`echo $prdList | awk '{print NF}'`
for gfx in {1..4}; do
gf=`echo $gfx | awk '{print ($1<4)?$1+3:8}'`
gfm=`echo $gf | awk '{printf "%02d\n",$1}'`
gfnx=`echo $gf | awk '{printf "%d%%\n",$1}'`
#
ts=""
makePlot in "infected" .4
makePlot tp "test positive" .02
ts=106
makePlot in "infected" ""
makePlot tp "test positive" ""
done
# rm V_?_???/{in,tp}_{c,[0-9][0-9]}.csv
open $dst