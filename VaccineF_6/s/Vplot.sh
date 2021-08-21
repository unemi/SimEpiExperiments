#! /bin/bash
tl=258 # August 31
nd=`pwd | awk -F/ '{print ($NF~/^V_[0-9]_[0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]/)?$NF:1}'`
if [ $nd = 1 ]; then echo "This command must run from V_9_999*."; exit; fi
vd=`echo $nd | awk -F_ '{print $3}'`
prs=`echo $nd | awk -F_ '{print $4}'`
prnx=`echo $prs | awk '{printf "%.1f%%/day",$1/10}'`
va=`echo $nd | awk -F_ '{print $5}'`
vax=`echo $va | awk '{printf "%d%%",$1}'`
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
rds="095"
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/VPF_$popN/${vd}_${prs}_$va"
if [ ! -d $dst ]; then mkdir -p $dst; fi
rd=`echo $rds | awk '{printf "%d\n",$1}'`
popx=`echo $popN | awk '{printf "%d0,000\n",$1*$1}'`
ed=22
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
#
makePlot () {
for vp in $vpList; do
  awk '$1>='$vd'{print}' V_${vp}_${vd}_${prs}_${va}/$3.csv > /tmp/$1A_${vp}.csv
done
echo plot $1A${ts}_$gfm.svg
gnuplot > $dst/$1A${ts}_$gfm.svg <<EOF
set terminal svg size 640 360
set label "Population size = ${popx}\nGathering frequency = ${gfnx}\nPerform rate = ${prnx}\n\
Exclusion rate = ${vax}"\
 at $vd+3,graph .3 left
set key right title "Vaccination priority"
set style data lines
set ylabel "$2 (%)"
set xrange [$ts:$tl]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ vaccine" at $vd,graph .45
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgbcolor "#660099"
array vpa[$nvp] = [ `echo $vpList | awk '{for(i=1;i<=NF;i++)printf "\"%s\",",$i}'` ]
array vpnm[5] = [ "random", "active individual", "central area", "dense area", "tracing dose" ]
array cl[$nvp]
do for [i=1:$nvp] { cl[i] = hsv2rgb((i-1.)/$nvp,1.,.667) }
plot 'NoVcn/$3.csv' using 1:$gfx+1 title "without vaccine" lc rgb "#999999",\
  for [i=1:$nvp] sprintf("/tmp/$1A_%s.csv",vpa[i]) using 1:$gfx+1 title vpnm[i] lc rgb cl[i]
EOF
rm /tmp/$1A_*
}
#
cd ..
vpList=`echo V_[0-9]_${vd}_${prs}_$va | \
 awk '{for(i=1;i<=NF;i++){split($i,a,"_");printf "%s ",a[2]};print ""}'`
nvp=`echo $vpList | awk '{print NF}'`
for gfx in {1..3}; do
gfm=`echo $gfx | awk '{printf "%02d\n",$1*5+5}'`
gfnx=`echo $gfm | awk '{printf "x%.1f\n",$1/10}'`
ts=106
makePlot in "infected" "infected"
makePlot tp "test positive" "testPositive"
done
# rm V_?_???/{in,tp}_{c,[0-9][0-9]}.csv
open $dst