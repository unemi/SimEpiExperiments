#! /bin/bash
pp=100
tgt="/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv"
bestN=8
cd MyResult_00
nn=0
for f in daily_*.csv; do
  n=`tail -1 $f | cut -d, -f1`
  if [ $nn -lt $n ]; then nn=$n; fi
done
n=0
rm -f XX; touch XX
for f in `ls daily_*.csv | sort -t_ -n -k2`; do
  awk -F, 'BEGIN{s=0;i=0;for(j=0;j<7;j++)q[j]=0}\
  $1>17{s+=$2-q[i];q[i]=$2;i=(i+1)%7;if(n<7)n++;if(n>=4)printf " %.4f\n",s/n/'$pp'}\
  END{for(j=$1;j<'$nn';j++)print " 0"}' $f > X$n
  if [ $n -ge 7 ]; then lam XX X[0-7] > XZ; mv -f XZ XX; n=0; else n=$((n+1)); fi
done
echo "XX was built."
nd=`awk 'END{print NR}' XX`
nf=`awk 'NR==1{print NF;exit}' XX`
cat $tgt XX | \
awk 'BEGIN{k=0;n=0;for(i=1;i<'$nf';i++)ds2[i]=0}\
  NF==3{if($1>356)r[n++]=$2/1396.0}\
  NF>3{if(k==0)sr=NR;if(k<=n){\
    for(i=1;i<=NF;i++){d=$i-r[k];ds2[i]+=d*d*(.25+((NR-sr)/'$nd')**2)}k++}}\
  END{for(i=1;i<=NF;i++)printf "%.6f %d\n",sqrt(ds2[i]/k),i}' | sort -n | \
awk 'NR<='$bestN'{printf "%.6f %d%s",$1,$2,(NR<'$bestN')?" ":""}' > XZ
echo "XZ was built."
makePlot () {
gnuplot > ../$1.svg <<EOF
set terminal svg size 640 300
set style data lines
set xrange [1:$tl]
if ("$2" eq "log") { set logscale y; set yrange [0.05:3.5] }
else { set yrange [:3.5] }
array D[$((bestN*2))] = [ `sed "s/ /,/g" XZ` ]
plot for [i=1:$bestN] 'XX' using 0:D[i*2] title sprintf("%d %d %.6f",i,D[i*2],D[i*2-1])\
 lc rgb hsv2rgb((i-1.)/$bestN,1.,.667),\
 '$tgt' using (\$1 - 356):(\$2 / 1396.0) title "Tokyo weekly" lc rgb "black"
EOF
}
makePlot ave linear
makePlot aveLog log
#
echo "" | cat XZ - XX | \
awk 'NR==1{n=NF/2;for(i=1;i<=n;i++)x[i]=$(i*2)}\
NR>1{s=0;for(i=1;i<=n;i++){s+=$(x[i]);printf "%.5f ",s/i}print ""}' > XV
makeAvPlot () {
gnuplot > ../$1.svg <<EOF
set terminal svg size 640 300
set style data lines
set xrange [1:$tl]
if ("$2" eq "log") { set logscale y; set yrange [0.05:3.5] }
else { set yrange [:3.5] }
plot for [i=1:$bestN] 'XV' using 0:i title sprintf("%d",i)\
 lc rgb hsv2rgb((i-1.)/$bestN,1.,.667),\
 '$tgt' using (\$1 - 356):(\$2 / 1396.0) title "Tokyo weekly" lc rgb "black"
EOF
}
makeAvPlot ave1 linear
makeAvPlot ave1log log
#
for b in {1..4}; do
x=`awk '{printf "%d\n",$('$b'*2)}' XZ`
awk '{printf "%d %.4f\n",NR+21,$'$x'}' XX > XY
awk -F, 'NR>1{printf "%d %.4f\n",$1,$2/'$pp'}' daily_${x}.csv > XW
gnuplot > ../aveBest${b}.svg <<EOF
set terminal svg size 640 300
set style data lines
set xrange [1:$tl]
plot 'XW' using 1:2 title "${x}", 'XY' using 1:2 title "Weekly",\
 '$tgt' using (\$1 - 338):(\$2 / 1396.0) title "Tokyo weekly" lc rgb "black"
EOF
done
echo "ave.svg and aveBest.svg were built."
#
i=1
for x in `awk '{for(i=2;i<=NF;i+=2)printf "%d ",$i;print ""}' XZ`; do
# if [ $x -le 10 ]; then m="simepi2"; n=$x
# elif [ $x -le 106 ]; then m="simepiM0$(((x-11)/12))"; n=$(((x-11)%12+1))
# else m="simepi"; n=$((x-106))
if [ $x -le 5 ]; then m="simepi2"; n=$x
elif [ $x -le 53 ]; then m="simepiM0$(((x-6)/6))"; n=$(((x-6)%6+1))
else m="simepi"; n=$((x-53))
fi
echo ./dlvState.sh $m `awk 'NR=='$n'{print}' ../jobID_$m`_1 \
`pwd | awk -F/ '{printf "%s_1M2_%d",$(NF-1),'$i'}'`
i=$((i+1))
done
rm -f X?
cd ..
