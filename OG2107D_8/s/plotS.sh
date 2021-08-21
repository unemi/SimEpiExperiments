#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
rd2=186;rd3=208;ed3=0
if [ $mk = "E" ];then rd3=208; ed3=236
elif [ $mk = "F" ]; then rd3=208; ed3=250
elif [ $mk = "M" ]; then rd3=216;
elif [ $mk = "M2" ]; then rd3=222; fi
ed=22 # January 7
rd=95 # March 21
md=117 # April 12
ed2=131 # April 26
tl=380
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
gnuplot > gfScinario.svg <<EOF
set terminal svg size 720 300
set key right bottom
set ylabel "gatherings frequency (‰)"
set style data lines
set xrange [1:$tl]
set xtics ($xmarks)
set label "emergency declaration" at $ed,graph .32
set label "stricter measures" at $md,graph .32
set label "election" at 191,graph .46
set label "Olympic" at 217,graph .36
set label "Obon" at 240.5,graph .46
set label "Paralympic" at 251,graph .36
set object rect from $ed,graph 0 to $rd,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $md,graph 0 to $ed2,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
set object rect from $ed2,graph 0 to $rd2,graph .3 back fc rgb "red" fs solid 0.1 lw 0
set object rect from $rd2,graph 0 to $rd3,graph .3 back fc rgb "yellow" fs solid 0.2 lw 0
if ("$ed3" > 0) {
set object rect from $rd3,graph 0 to $ed3,graph .3 back fc rgb "red" fs solid 0.1 lw 0
}
set object rect from 191,graph .3 to 200,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 217,graph .3 to 235,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 240.5,graph .3 to 243.5,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
set object rect from 251,graph .3 to 263,graph .6 back fc rgb "blue" fs solid 0.1 lw 0
plot 'gatFreq.csv' using 1:2 title "gat.freq." lc rgb "#888844"
EOF
#
