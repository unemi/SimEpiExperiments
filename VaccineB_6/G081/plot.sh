#! /bin/bash
nd=`pwd | awk -F/ '{print $NF}'`
fl=`(cd ..;echo G???) |\
 awk '{for(i=2;i<=NF;i++)if($i=="'$nd'")printf "%d\n",substr($(i-1),2,3)}'`
sc=`pwd | awk -F/ '{d=$(NF-1);n=substr(d,length(d),1);print 1./(n*n*100)}'`
w=`awk '/worstIN/{print $2+1}' aveResult.txt`
b=`awk '/bestIN/{print $2+1}' aveResult.txt`
m=`awk '/middleIN/{print $2+1}' aveResult.txt`
a=`awk -F, 'NR==1{print NF-1}' aveIN.csv`
tl=`tail -4 aveIN.csv | head -1 | cut -d, -f1`
gnuplot > aveIN.svg <<EOF
set terminal svg size 640 300
set style data lines
set ylabel "infected"
set xrange [$fl*16:$tl]
set datafile separator comma
plot 'aveIN.csv' using 1:$b title "best", '' using 1:$w title "worst",\
  '' using 1:$m title "middle", '' using 1:$a title "average"
EOF
#
w=`awk '/worstTP/{print $2+1}' aveResult.txt`
b=`awk '/bestTP/{print $2+1}' aveResult.txt`
m=`awk '/middleTP/{print $2+1}' aveResult.txt`
a=`awk -F, 'NR==1{print NF-1}' aveTP.csv`
tl=`tail -4 aveTP.csv | head -1 | cut -d, -f1`
gnuplot > aveTP.svg <<EOF
set terminal svg size 640 300
set style data lines
set ylabel "test positive"
set xrange [$fl:$tl]
set datafile separator comma
plot 'aveTP.csv' using 1:$b title "best", '' using 1:$w title "worst",\
  '' using 1:$m title "middle", '' using 1:$a title "average"
EOF
