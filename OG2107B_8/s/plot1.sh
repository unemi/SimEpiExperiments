#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
pr=`echo $dirName | awk -F_ '{printf "%d\n",(NF>1)?$2:0}'`
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
spd=12 # steps per day
ed=22 # January 7
rd=95 # March 21
md=117 # April 12
ed2=131 # April 26
rd2=186 # June 20
elS=191 # June 25 Tokyo election start
elV=200 # July 4 Election day
ogO=217 # July 21, Olympic games
ogC=235 # August 8
pgO=251 # August 24, Parlympic games
pgC=263 # September 5
if [ "$mk" = "E" ]; then rd2=$((rd2+`echo $dirName | awk -F_ '{printf "%d",$4}'`)); fi
dfs=(MyResult_*/daily_*.csv)
if [ ${#dfs[@]} -le 1 ]; then echo "No data files"; exit; fi 
tl=`awk -F, 'END{print $1}' $dfs`
#
makeDataFile () {
echo $d | awk -F_ '{printf "\t\"%d%%\"\t\"U%s\"\t\"L%s\"\n",$2*20,$2,$2}' > $1.csv
awk -F, '$1>0{x+='$3';n++;if($1%'$4'==0)\
{z=x/n;k=$1/'$4';v[k]+=z;v2[k]+=z*z;nv[$1/'$4']++;x=0;n=0}}\
 END{for(i=1;nv[i]>0;i++){e=v[i]/nv[i]/'$pop'.;s=sqrt((v2[i]-v[i]*v[i]/nv[i])/nv[i])/'$pop'.;\
 printf "\t%.'$5'f\t%.'$5'f\t%.'$5'f\n",e,e+s,e-s}}' $2_*.csv >> $1.csv
}
for d in MyResult_??; do
cd $d
for f in daily_*.csv; do
awk -F, 'NR==1{i=0;for(j=2;j<=NF;j++){s[j]=0;for(k=0;k<7;k++)q[j*7+k]=0}print}\
$1>0{if(n<7)n++;for(j=2;j<=NF;j++){k=j*7+i;s[j]+=$j-q[k];q[k]=$j}i=(i+1)%7;\
if(n>=4){printf "%s",$1-3;for(j=2;j<=NF;j++){printf ",%.4f",s[j]/n}print ""}}\
END{for(a=1;a<=3;a++){printf "%d",$1-3+a;n--;\
for(j=2;j<=NF;j++){s[j]-=q[j*7+i];printf ",%.4f",s[j]/n}print ""}}'\
 $f > weekly_`echo $f | awk -F_ '{print $2}'`
done
makeDataFile IN indexes '$2+$3' $spd 6
makeDataFile TP weekly '$2' 1 8
makeDataFile VC indexes '$6' $spd 6
cd ..
done
#
echo '"day"' > z.csv
for ((x=cmd;x<=tl;x++)); do echo $x >> z.csv; done
lam z.csv MyResult_??/IN.csv > IN.csv
lam z.csv MyResult_??/TP.csv > TP.csv
lam z.csv MyResult_??/VC.csv > VC.csv
rm z.csv
#
# dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/K_$popN"
# if [ ! -d $dst ]; then mkdir -p $dst; fi
nf=`awk 'NR==2{print NF}' IN.csv`
#
LANG=C
tspan=$(((tl-1)/10))
declare -a arr
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
prx=`echo $pr | awk '{printf "%.1f%%\n",$1/10}'`
#
makePlot () {
echo plot $1.svg
gnuplot > $1.svg <<EOF
if ("$1" eq "IN") { set terminal svg size 640 300; set ylabel "infected (%)" }
else { set terminal svg size 720 300; set ylabel "weekly test positive (%)" }
set style data lines
set xrange [1:$tl]
if ("$1" eq "IN") { set yrange [0:.3] }
else { set yrange [0:.014]; set y2label "1st dose vaccinated (%)"; set y2tics }
set xtics ($xmarks)
set label "emergency declaration" at $ed,graph .56
set label "stricter measures" at $md,graph .63
set label "emergency declaration" at $ed2,graph .56
set label "Election" at $elS,graph .63
set label "Olympic" at $ogO,graph .56
set label "Paralympic" at $pgO,graph .56
set object rect from $ed,graph 0 to $rd,graph .5 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $md,graph 0 to $ed2,graph .5 back fc rgb "yellow" fs solid 0.5 lw 0
set object rect from $ed2,graph 0 to $rd2,graph .5 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $elS,graph 0 to $elV,graph .5 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from $ogO,graph 0 to $ogC,graph .5 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from $pgO,graph 0 to $pgC,graph .5 back fc rgb "blue" fs solid 0.1 lw 0
set key right
set label "Population size = ${popx}" at screen .5,.85 center
if ("$1" eq "IN") { plot '$1.csv' using 1:2 title "average" lc rgb "#880000",\
 '' using 1:3 title "?? ?? ??" dt 2 lc rgb "#880000",\
 '' using 1:4 notitle dt 2 lc rgb "#880000" }
else { plot '$1.csv' using 1:2 title "average" lc rgb "#880000",\
 '' using 1:3 title "?? ?? ??" dt 2 lc rgb "#880000",\
 '' using 1:4 notitle dt 2 lc rgb "#880000",\
 '/Users/unemi/Research/SimEpidemicPJ/?????????PJ/??????????????????/nhk_pref_weekly/13?????????.csv'\
  using (\$1 - 316 - $ed):(\$2 / 139600.0) title "Tokyo" lc rgb "#008800" lw 2,\
 'VC.csv' using 1:2 axes x1y2 title "vaccinated" lc rgb "#440088" }
EOF
}
#
makePlot IN
makePlot TP
#
# open $dst
