#! /bin/bash
getPeaks () {
  local dir=`pwd`
  local m=`echo $1 | awk -F_ '{k=(length($1)+1)/2;print (k<3)?k:($1=="VSD60")?3:4}'`
  cd $1
  for pr in 02 04 06; do
  awk 'NR>1{for(i=0;i<3;i++)if(v[i]<$(i+2)){v[i]=$(i+2);idx[i]=$1-'$vd'}}\
  END{printf "%f",'$m'*.4+'$pr'-1.;for(i=0;i<3;i++)printf "\t%s\t%s",idx[i],v[i];print ""}'\
    $pr/infected.csv > ../V_$dx/VSDPeaks`echo $m $pr | awk '{print ($1-1)*3+$2/2}'`.csv
  done
  cd $dir
}
makePlot () {
for gf in 5 6; do
  dc=`expr $gf \* 2 - 6`
  vc=`expr $gf \* 2 - 5`
  gnuplot > $dst/peakSDI_0$gf.svg <<EOF
set terminal svg size 320 300
# set label "Lifting $rdDate, Vaccine $vdDate\nGathering frequency = ${gf}%"\
#  at screen .5,.9 center front
set style data boxes
set boxwidth .28
set xlabel "perform rate (per population day)"
set xrange [1:7]
set xtics ("0.2%%" 2, "0.4%%" 4, "0.6%%" 6) nomirror
set ylabel "peak infected (%)"
set yrange [0:]
plot for [i=1:12] z=(i-1)/3+1 sprintf("V_$dx/VSDPeaks%d.csv",i) using 1:$vc notitle\
    fillstyle border dt z lc rgb hsv2rgb(((i-1)%3)/3.,1.,.8) lw 1.5
EOF
  gnuplot > $dst/peakSDD_0$gf.svg <<EOF
set terminal svg size 320 300
# set label "Lifting $rdDate, Vaccine $vdDate\nGathering frequency = ${gf}%"\
#  at screen .5,.9 center front
set style data boxes
set boxwidth .28
set xlabel "perform rate (per population day)"
set xrange [1:7]
set xtics ("0.2%%" 2, "0.4%%" 4, "0.6%%" 6) nomirror
set ylabel "peak days from vaccination"
set yrange [0:$tl-$vd]
plot for [i=1:12] z=(i-1)/3+1 sprintf("V_$dx/VSDPeaks%d.csv",i) using 1:$dc notitle\
    fillstyle border dt z lc rgb hsv2rgb(((i-1)%3)/3.,1.,.8) lw 1.5
EOF
# plot 'V_$dx/VSDPeaks1.csv' using (\$1*.2+\$2-.9):$vc title "peak infected",\
#  '' using (\$1*.2+\$2-.1):$dc title "peak day" axis x1y2
done
}
tl=258 # August 31
dx=`pwd | awk -F/ '{if($NF ~ /V_[0-9][0-9][0-9]_[0-9][0-9][0-9]/)print substr($NF,3,7);\
 else print 1}'`
if [ $dx = 1 ]; then echo "This command should run from V_999_999."; exit; fi
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/V_$dx"
rd=`echo $dx | cut -d_ -f1`
vd=`echo $dx | cut -d_ -f2`
LANG=C
rdDate=`date -j -v+${rd}d 121601002020 "+%b %e" | sed 's/  / /'`
vdDate=`date -j -v+${vd}d 121601002020 "+%b %e" | sed 's/  / /'`
LANG=ja_JP.UTF-8
cd ..
getPeaks V_$dx
getPeaks VSD_$dx
getPeaks VSD60_$dx
getPeaks VSD30_$dx
makePlot
echo V_$dx
