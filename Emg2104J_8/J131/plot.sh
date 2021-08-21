#! /bin/bash
if [ ! -f aveResult.txt ]; then echo "aveResult.txt doesn't exist."; exit; fi
sc=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);print n*n*100}'`
w=`awk '/worstIN/{print $2+1}' aveResult.txt`
b=`awk '/bestIN/{print $2+1}' aveResult.txt`
m1=`awk '/IN1/{print $2+1}' aveResult.txt`
m2=`awk '/IN2/{print $2+1}' aveResult.txt`
m3=`awk '/IN3/{print $2+1}' aveResult.txt`
a=`awk -F, 'NR==1{print NF-1}' aveIN.csv`
awk -F, '$1!~/D/{printf "%.4f",$1/16;for(i=2;i<=NF;i++)printf "\t%.6f",$i/'$sc';print ""}'\
 aveIN.csv > aveINn.csv
#
tl=`tail -1 aveINn.csv | cut -f1`
declare -a arr
LANG=C
local tspan=$(((tl-1)/10))
for ((x=0;x<10;x++)); do local d=$((x*tspan+tspan/2+1))
arr[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
xmarks="${arr[*]}"
LANG=ja_JP.UTF-8
#
gnuplot > aveIN_Log.svg <<EOF
set terminal svg size 640 300
set style data lines
set ylabel "infected (%)"
set xrange [1:$tl]
set xtics ($xmarks)
#set yrange [0:.4]
set logscale y
plot 'aveINn.csv' using 1:$b title "best", '' using 1:$w title "worst",\
  '' using 1:$m1 title "middle1",'' using 1:$m2 title "middle2",'' using 1:$m3 title "middle3",\
  '' using 1:$a title "average"
EOF
#
w=`awk '/worstTP/{print $2+1}' aveResult.txt`
b=`awk '/bestTP/{print $2+1}' aveResult.txt`
m=`awk '/middleIN/{print $2+1}' aveResult.txt`
a=`awk -F, 'NR==1{print NF-1}' aveTP.csv`
awk -F, '$1!~/D/{printf "%d",$1;for(i=2;i<=NF;i++)printf "\t%.8f",$i/'$sc';print ""}'\
 aveTP.csv > aveTPn.csv
tl=`tail -1 aveTPn.csv | cut -f1`
gnuplot > aveTP_Log.svg <<EOF
set terminal svg size 640 300
set style data lines
set ylabel "test positive (%)"
set xrange [1:$tl]
set xtics ($xmarks)
#set yrange [0:.028]
set logscale y
plot 'aveTPn.csv' using 1:$b title "best", '' using 1:$w title "worst",\
  '' using 1:$m1 title "middle1",'' using 1:$m2 title "middle2",'' using 1:$m3 title "middle3",\
  '' using 1:$a title "average",\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - 22):(\$2 / 137240.0) title "Tokyo weekly",\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref/13東京都.csv'\
  using (\$1 - 312 - 22):(\$2 / 137240.0) title "Tokyo daily"
EOF
