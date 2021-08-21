#! /bin/bash
pp=`pwd | awk -F/ '{x=substr($(NF-1),length($(NF-1)),1);print x*x}'`
tgt="/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv"
cd MyResult_00
nn=0
for f in daily_*.csv; do
  n=`tail -1 $f | cut -d, -f1`
  if [ $nn -lt $n ]; then nn=$n; fi
done
n=0
rm -f XX; touch XX
for f in `ls daily_*.csv | sort -t_ -n -k2`; do
  awk -F, '$1>17{s+=$2-q[i];q[i]=$2;i=(i+1)%7;if(n<7)n++;if(n>=4)printf " %.4f\n",s/n/'$pp'}\
  END{for(j=$1;j<'$nn';j++)print " 0"}' $f > X$n
  if [ $n -ge 7 ]; then lam XX X[0-7] > XZ; mv -f XZ XX; n=0; else n=$((n+1)); fi
done
echo "XX was built."
cat $tgt XX | \
awk 'NF==3{if($1>356)r[n++]=$2/1372.40}\
  NF>3{if(k<=n){for(i=1;i<=NF;i++){d=$i-r[k];ds2[i]+=d*d}k++}}\
  END{for(i=1;i<=NF;i++)printf "%.6f %d\n",sqrt(ds2[i]/k),i}' | sort -n | \
awk 'NR<6{printf "%d%s",$2,(NR<5)?", ":""}' > XZ
echo "XZ was built."
gnuplot > ../ave2.svg <<EOF
set terminal svg size 640 300
set style data lines
set xrange [1:84]
array D[5] = [ `cat XZ` ]
plot for [i=1:5] 'XX' using 0:D[i] title sprintf("%d %d",i,D[i])\
 lc rgb hsv2rgb((i-1)/5.0,1.,.667),\
 '$tgt' using (\$1 - 356):(\$2 / 1372.40) title "Tokyo weekly" lc rgb "black"
EOF
x=`awk -F, '{print $1}' XZ`
gnuplot > ../ave2Best.svg <<EOF
set terminal svg size 640 300
set style data lines
set datafile separator comma
plot 'daily_${x}.csv' using 1:2 title "${x}"
EOF
echo "ave2.svg and ave2Best.svg were built."
if [ $x -le 4 ]; then m="simepi2"; n=$x
elif [ $x -le 52 ]; then m="simepiM0$(((x-5)/6))"; n=$(((x-5)%6+1))
elif [ $x -le 64 ]; then m="simepi"; n=$((x-52))
elif [ $x -le 68 ]; then m="simepi2"; n=$((x-64))
elif [ $x -le 116 ]; then m="simepiM0$(((x-69)/6))"; n=$(((x-69)%6+1))
else m="simepi"; n=$((x-116))
fi
if [ $x -le 64 ]; then d="/1"; else d=""; fi
echo ./dlvState.sh $m `cat ..$d/jobID_$m`_$n \
`pwd | awk -F/ '{n=substr($(NF-2),length($(NF-2)),1);printf "%s_%d0K",$(NF-1),n*n}'`
rm -f X?
cd ..
