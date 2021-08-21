#! /bin/bash
makePlot () {
gnuplot > TPALL-$1.svg <<EOF
set datafile separator comma
set terminal svg size 720 300
set ylabel "weekly test positive (%)"
set style data lines
if ("$1" eq "log") { set logscale y } 
plot for [i=1:64] sprintf("MyResult_00/weekly_%d.csv",i) using 1:2 notitle
EOF
}
if [ ! -f MyResult_00/weekly_1.csv ]; then
cd MyResult_00
for f in daily_*.csv; do
awk -F, 'NR==1{i=0;for(j=2;j<=NF;j++){s[j]=0;for(k=0;k<7;k++)q[j*7+k]=0}print}\
$1>0{if(n<7)n++;for(j=2;j<=NF;j++){k=j*7+i;s[j]+=$j-q[k];q[k]=$j}i=(i+1)%7;\
if(n>=4){printf "%s",$1-3;for(j=2;j<=NF;j++){printf ",%.4f",s[j]/n}print ""}}\
END{for(a=1;a<=3;a++){printf "%d",$1-3+a;n--;\
for(j=2;j<=NF;j++){s[j]-=q[j*7+i];printf ",%.4f",s[j]/n}print ""}}'\
 $f > weekly_`echo $f | awk -F_ '{print $2}'`
done
cd ..
fi
makePlot linear
makePlot log