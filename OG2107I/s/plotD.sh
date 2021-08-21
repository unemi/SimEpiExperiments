#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
sd=`echo $dirName | awk -F_ '{print $3}'`
pop=10000
tl=0
for f in MyResult_??/daily_*.csv; do
 x=`awk -F, 'END{print $1}' $f`
 if [ $tl -lt $x ]; then tl=$x; fi
done
#
for d in ../${mk}_??_${sd}; do
pushd $d > /dev/null
awk -F, '$1%12==0{if($1=="")d1=0;else{d2=$5;z=d2-d1;d1=d2;\
 k=$1/12;v[k]+=z;v2[k]+=z*z;nv[k]++}}\
 END{for(i=1;nv[i]>0;i++){e=v[i]/nv[i]/'$pop'.;\
 vv=(v2[i]-v[i]*v[i]/nv[i])/nv[i];if(vv<0)s=0;else s=sqrt(vv)/'$pop'.;\
 printf "%d %.8f %.8f\n",i,e,s}}' MyResult_00/indexes_*.csv > DT.csv
 awk '$1>=223{print}' DT.csv > DTSub.csv
popd > /dev/null
done
#
LANG=C
tspan=$(((tl-1)/10))
declare -a arr
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
#
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/OH_10"
#
gnuplot > $dst/${mk}_${sd}_D.svg <<EOF
set terminal svg size 680 300
set style data lines
set ylabel "death (%)"
set yrange [0:]
set xrange [1:$tl]
set xtics ($xmarks)
array col[4] = [ "#990000", "#707000", "#008800", "#0000cc" ]
array vcol[4] = [ "#ffaaaa", "#ddddaa", "#aaffaa", "#aaaaff" ]
array dirs[4]
array bsx[4]
do for [i=1:4] {
 dirs[i] = sprintf("../${mk}_%02d_${sd}/",(i-1)*10)
 bsx[i] = sprintf("%d%%",(i-1)*10)
}
plot for [i=1:3] dirs[i]."DTSub.csv" using 1:2 title bsx[i] lc rgb col[i] lw 2,\
 for [i=1:3] dirs[i]."DTSub.csv" using 1:(\$2 + \$3) notitle dt 2 lc rgb col[i],\
 for [i=1:3] dirs[i]."DTSub.csv" using 1:(\$2 - \$3) notitle dt 2 lc rgb col[i],\
 dirs[4]."DT.csv" using 1:2 title bsx[4] lc rgb col[4] lw 2,\
 dirs[4]."DT.csv" using 1:(\$2 + \$3) notitle dt 2 lc rgb col[4],\
 dirs[4]."DT.csv" using 1:(\$2 - \$3) notitle dt 2 lc rgb col[4]
EOF
open $dst