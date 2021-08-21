#! /bin/bash
#
plotE () {
local nm=${outfn}_E
local bv=`echo $outfn | awk -F_ '{printf "%s_%s_BVcn\n",$1,$2}'`
local nf=`head -1 $outfn.csv | wc -w`
echo plot $nm.svg
gnuplot > $dst/$nm.svg <<EOF
set terminal svg size 640 240
set label "Population size = `expr $pop / 10`,000\nGathering frequency = ${gf}%"\
 at screen .5,.85 center
set key right bottom title "perform rate" left
set style data lines
set ylabel "$1 (%)"
set xrange [$fl:$tl]
set yrange [:$2]
set xtics ("Mar 7" 81, "Apr 1" 106, "May 1" 136,\
 "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
set label "→ lifting\n $rdDate" at $rd,graph .65
set label "→ vaccine\n $vdDate" at $vd,graph .45
set arrow from 22,graph 0 to 22,graph 1 nohead lc rgbcolor "red"
set arrow from $rd,graph 0 to $rd,graph .7 nohead lc rgbcolor "#008800"
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgbcolor "#660099"
plot '$bv.csv' notitle lc rgb "#666666",\
 for [i=2:${nf}] '$outfn.csv' using 1:i title columnhead lc rgb hsv2rgb((i-1.)/${nf},1,.8)
EOF
}
#
gf=2  # gathering frequency after lifting the emergency delaration
if [ $# -gt 0 ]; then gf=$1; fi
tl=258
fl=74
ss=`pwd | awk -F/ '{for(i=NF;i>1;i--)if(split($i,a,"_")==3){printf "%s %s\n",$(i-1),$i;exit}}'`
nd=`echo $ss | awk '{print substr($2,4,7)}'`  # ex. 074_106 = Feb28 lift, Apr1 vaccine
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/V_G$nd"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`echo $ss | awk '{n=substr($1,length($1),1);printf "%d\n",n*n*100}'`
rd=`echo $nd | awk -F_ '{printf "%d\n",$1}'`
vd=`echo $nd | awk -F_ '{print $2}'`
vdStep=`expr $vd \* 16`
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e"`
vdDate=`date -j -v+${vd}d 121601002020 "+%b %e"`
LANG=ja_JP.UTF-8
#
cd V$gf
# for cc in fair worse; do
for cc in fair ; do
outfn=in_${cc}_A_${gf}
plotE "infected" .05
outfn=tp_${cc}_A_${gf}
plotE "test positive" .0025
done
#
open $dst