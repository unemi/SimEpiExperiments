#! /bin/bash
nd=`pwd | awk -F/ '{print ($NF~/^EV_[0-9][0-9]/)?$NF:1}'`
if [ $nd = 1 ]; then echo "This command must run from EV_99."; exit; fi
if [ ! -f MyResult_00/indexes_1.csv ]
  then echo "MyResult_00/indexes_1.csv doesn't exist."; exit; fi
edDur=`echo $nd | cut -d_ -f2`
edDay=117 # April 12
vcnDay=`echo $nd | awk -F_ '{print (NF<3)?999:$3}'`
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/EV_$popN"
if [ ! -d $dst ]; then mkdir -p $dst; fi
pop=`echo $popN | awk '{printf "%d\n",$1*$1*100}'`
popx=`echo $popN | awk '{printf "%d0,000\n",$1*$1}'`
commonCSV="../H106/to106.csv"
if [ ! -f $commonCSV ]; then
  cd MyResult_00
  echo '"day"' > ../DY; echo ' "IN"' > ../IN; echo ' "TP"' > ../TP
  for ((x=1;x<=106;x++)); do echo $x >> ../DY; done
  awk -F, 'NR>1 && $1<=106*12 && $1%12==0 {printf " %.6f\n",($2+$3)/'$pop'}' \
   indexes_1.csv >> ../IN
  awk -F, 'NR>1 && $1<=106 {printf " %.8f\n",$2/'$pop'}' daily_1.csv >> ../TP
  cd ..
  lam DY IN TP > $commonCSV
  rm -f DY IN TP
  echo "$commonCSV was built."
fi
if [ ! -f IN.txt ]; then
for d in MyResult_??; do
rn=`echo $d | cut -d_ -f2`
cd $d
tl=0;
for f in daily_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $tl -lt $nn ]; then tl=$nn; fi
done
nn=0; rm -f XX; touch XX
for f in indexes_*.csv; do
  awk -F, '$1>=106*12 && $1%12==0{printf " %d\n",$2+$3}' $f > X$nn
  if [ $nn -eq 7 ]; then nn=0; lam XX X[0-7] > XZ; mv -f XZ XX
  else nn=$((nn+1)); fi
done
awk '{s=0;for(i=1;i<=NF;i++)s+=$i;printf " %.6f\n",s/NF/'$pop'}' XX > ../IN_$rn
nn=0; rm -f XX; touch XX
for f in daily_*.csv; do
  awk -F, '$1>=106{printf " %d\n",$2}' $f > X$nn
  if [ $nn -eq 7 ]; then nn=0; lam XX X[0-7] > XZ; mv -f XZ XX
  else nn=$((nn+1)); fi
done
awk '{s=0;for(i=1;i<=NF;i++)s+=$i;printf " %.8f\n",s/NF/'$pop'}' XX > ../TP_$rn
rm -f X?
cd ..
done
rm -f DY
for ((x=106;x<=tl;x++)); do echo $x >> DY; done
lam DY IN_?? > IN.txt
lam DY TP_?? > TP.txt
rm -f DY IN_?? TP_??
fi
sfx=`echo $edDur $vcnDay | awk '{if($2>=999)printf "%d\n",$1;else printf "%d_%d\n",$1,$2}'`
#
nf=`awk 'NR==1{print NF;exit}' IN.txt`
ts=1
cat > GP <<EOF
set terminal svg size 640 320
set label "Population size = ${popx}" at graph 0.95,graph 0.1 right
set object rect from $edDay,graph 0 rto $edDur,graph 1 back fc rgb "red" fs solid 0.1 lw 0
set label "→ vaccine" at $vcnDay,graph .05 left
set arrow from $vcnDay,graph 0 to $vcnDay,graph .6 back nohead lc rgb "#440099"
set style data lines
set key left title "Variant spread"
set xrange [$ts:$tl]
set xtics ("Jan 7" 22, "Feb 7" 53, "Mar 7" 81, "Apr 1" 106,\
 "May 1" 136, "Jun 1" 167, "Jul 1" 197, "Aug 1" 228)
array evDay[3] = [ "Apr 1", "Apr 8", "Apr 15" ]
EOF
echo plot IN${sfx}.svg
cat GP - <<EOF | gnuplot > $dst/IN${sfx}.svg
set ylabel "infected (%)"
set yrange [:0.4]
plot '$commonCSV' using 1:"IN" notitle lc rgb "#999999",\
  for [i=2:$nf] 'IN.txt' using 1:i title evDay[i-1] lc rgb hsv2rgb((i-2)/$nf.0,1.,.667)
EOF
#
echo plot TP${sfx}.svg
cat GP - <<EOF | gnuplot > $dst/TP${sfx}.svg
set ylabel "test positive (%)"
set yrange [:0.02]
plot '$commonCSV' using 1:"TP" notitle lc rgb "#999999",\
  for [i=2:$nf] 'TP.txt' using 1:i title evDay[i-1] lc rgb hsv2rgb((i-2)/$nf.0,1.,.667),\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
 using (\$1 - 338):(\$2 / 137240) title "Tokyo weekly" lc rgb "#008800"
EOF
rm GP
#
open $dst