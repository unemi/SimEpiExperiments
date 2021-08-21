#! /bin/bash
sc=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);print n*n*100}'`
w=`awk '/worstIN/{print $2+1}' aveResult.txt`
b=`awk '/bestIN/{print $2+1}' aveResult.txt`
m=`awk '/middleIN/{print $2+1}' aveResult.txt`
a=`awk -F, 'NR==1{print NF-1}' aveIN.csv`
awk -F, '$1!~/D/{printf "%.4f",$1/16;for(i=2;i<=NF;i++)printf "\t%.6f",$i/'$sc';print ""}'\
 aveIN.csv > aveINn.csv
tl=`tail -1 aveINn.csv | cut -f1`
gnuplot > aveIN.svg <<EOF
set terminal svg size 640 300
set style data lines
set ylabel "infected (%)"
set xrange [1:$tl]
set xtics ("Dec 24" 8, "Jan 7" 22, "Jan 14" 29, "Jan 21" 36, "Jan 28" 43,\
 "Feb 7" 53, "Feb 14" 60, "Feb 21" 67, "Feb 28" 74, "Mar 7" 81, "Apr 1" 106)
set yrange [0:.4]
plot 'aveINn.csv' using 1:$b title "best", '' using 1:$w title "worst",\
  '' using 1:$m title "middle", '' using 1:$a title "average"
EOF
#
w=`awk '/worstTP/{print $2+1}' aveResult.txt`
b=`awk '/bestTP/{print $2+1}' aveResult.txt`
m=`awk '/middleIN/{print $2+1}' aveResult.txt`
a=`awk -F, 'NR==1{print NF-1}' aveTP.csv`
awk -F, '$1!~/D/{printf "%d",$1;for(i=2;i<=NF;i++)printf "\t%.8f",$i/'$sc';print ""}'\
 aveTP.csv > aveTPn.csv
tl=`tail -1 aveTPn.csv | cut -f1`
gnuplot > aveTP.svg <<EOF
set terminal svg size 640 300
set style data lines
set ylabel "test positive (%)"
set xrange [1:$tl]
set xtics ("Dec 24" 8, "Jan 7" 22, "Jan 14" 29, "Jan 21" 36, "Jan 28" 43,\
 "Feb 7" 53, "Feb 14" 60, "Feb 21" 67, "Feb 28" 74, "Mar 7" 81, "Apr 1" 106)
# set datafile separator comma
set yrange [0:.028]
plot 'aveTPn.csv' using 1:$b title "best", '' using 1:$w title "worst",\
  '' using 1:$m title "middle", '' using 1:$a title "average",\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref_weekly/13東京都.csv'\
  using (\$1 - 316 - 22):(\$2 / 137240.0) title "Tokyo weekly",\
 '/Users/unemi/Research/SimEpidemicPJ/内閣府PJ/統計データ/nhk_pref/13東京都.csv'\
  using (\$1 - 312 - 22):(\$2 / 137240.0) title "Tokyo daily"
EOF
