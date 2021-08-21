#! /bin/bash
ed=22 # January 7
rd=95 # March 21
md=117 # April 12
ed2=131 # April 26
rd2=186 # `echo $dirName | awk -F_ '{printf "%d\n",(NF>1)?$3:166}'`
elS=191 # June 25 Tokyo election start
elV=200 # July 4 Election day
ogO=217 # July 21, Olympic games
ogC=235 # August 8
pgO=251 # August 24, Parlympic games
pgC=263 # September 5
tl=288 # September 30
#
LANG=C
tspan=$(((tl-1)/10))
for ((x=0;x<10;x++)); do d=$((x*tspan+tspan/2+1))
xmarks[$x]=\"`date -j -v+${d}d 121601002020 "+%b %e" | sed 's/  / /'`\"" $d,"
done
LANG=ja_JP.UTF-8
#
gnuplot > GF.svg <<EOF
set terminal svg size 640 300
set ylabel "Gathering frequency"
set xrange [1:$tl]
set xtics (${xmarks[@]})
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
set label "Scenario" at screen .5,.85 center
plot 
EOF
}
#
makePlot IN
makePlot TP
#
# open $dst
