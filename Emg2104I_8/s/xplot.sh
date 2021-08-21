#! /bin/bash
nd=`pwd | awk -F/ '{print ($NF~/^V_[0-9]/)?$NF:1}'`
if [ $nd = 1 ]; then echo "This script must run from V_?."; exit; fi
pr=`echo $nd | awk -F_ '{print $2}'`
popN=`pwd | awk -F/ '{print substr($(NF-1),length($(NF-1)),1)}'`
pop=`echo $popN | awk '{print $1*$1*100}'`
popx=`echo $pop | awk '{printf "%d,000\n",'$pop'/10}'`
spd=12 # steps per day
ed=22 # January 7
rd=95 # March 21
md=117 # April 12
vd=131 # vaccination start day (April 26)
tl=258 # August 31
cmd=131
vpNames=("random" "active individual" "dense area" "contacts")
#
makeNoVcn () {
if [ ! -f ../V_0/${1}0.csv ]; then
if [ ! -f ../V_0/MyResult_00/$2_1.csv ]
then echo "MyResult_00/$2_1.csv doesn't exist.";exit; fi
awk -F, '$1>0{x+='$3';n++;if($1%'$4'==0){v[$1/'$4']+=x/n;nv[$1/'$4']++;x=0;n=0}}\
 END{for(i=1;nv[i]>0;i++)printf "%.'$5'f\n",v[i]/nv[i]/'$pop'.}'\
 ../V_0/MyResult_00/$2_*.csv > ../V_0/${1}0.csv
fi
}
#
makeNoVcn IN indexes '$2+$3' $spd 6
makeNoVcn TP daily '$2' 1 8
#
makeDataFile () {
echo ${vpNames[`echo $d | cut -d_ -f2`]} | awk '{printf "\t\"%s\"\n",$0}' > $1.csv
awk -F, '$1>='$cmd'*'$4'{x+='$3';n++;if($1%'$4'==0){v[$1/'$4']+=x/n;nv[$1/'$4']++;x=0;n=0}}\
 END{for(i='$cmd';nv[i]>0;i++)printf "\t%.'$5'f\n",v[i]/nv[i]/'$pop'.}' $2_*.csv >> $1.csv
}
for d in MyResult_??; do
cd $d
makeDataFile IN indexes '$2+$3' $spd 6
makeDataFile TP daily '$2' 1 8
cd ..
done
#
echo '"day"' > z.csv
for ((x=cmd;x<=tl;x++)); do echo $x >> z.csv; done
lam z.csv MyResult_??/IN.csv > IN.csv
lam z.csv MyResult_??/TP.csv > TP.csv
rm z.csv
#
echo P
dst="/Users/unemi/Program/SimEpidemic/Documents/Figures/I_$popN"
if [ ! -d $dst ]; then mkdir -p $dst; fi
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
#
makePlot () {
echo plot $1_$pr.svg
gnuplot > $dst/$1_$pr.svg <<EOF
set terminal svg size 640 300
set label "Population size = ${popx}\nPerform rate = 0.${pr}%" at screen .5,.85 center
set key right bottom title "vaccine priority" right
set style data lines
if ("$1" eq "IN") { set ylabel "infected (%)" }
else { set ylabel "test positive (%)" }
set xrange [1:$tl]
if ("$1" eq "IN") { set yrange [:.4] }
else { set yrange [:.02] }
set xtics ($xmarks)
set label "→ emergency declaration" at $ed,graph .7
set label "→ lift declaration" at $rd,graph .6
set label "→ stricter measures" at $md,graph .5
set label "→ vaccine" at $vd,graph .4
set arrow from $ed,graph 0 to $ed,graph .8 nohead lc rgb "#884400"
set arrow from $rd,graph 0 to $rd,graph .7 nohead lc rgb "#004488"
set arrow from $md,graph 0 to $md,graph .6 nohead lc rgb "#888800"
set arrow from $vd,graph 0 to $vd,graph .5 nohead lc rgb "#880088"
plot '../V_0/${1}0.csv' using 0:1 title "no vaccine" lc rgb "#999999",\
  for [i=2:${nf}] '$1.csv' using 1:i title columnhead lc rgb hsv2rgb((i-2.)/($nf-1),1.,.667)
EOF
}
#
makePlot IN
makePlot TP
#
open $dst
