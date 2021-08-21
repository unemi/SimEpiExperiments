#! /bin/csh
setenv LANG C
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd |\
 awk -F/ '{printf "%s_%s\n",$(NF-1),$NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk -F/ '{n=substr($(NF-1),length($(NF-1)),1);printf "%d\n",n*n*100}'`
set rd=`pwd | awk -F/ '{split($(NF-1),a,"_");print a[2]}'`
set rs=`date -j -v+${rd}d 121801002020 "+%b %e" | sed "s/  / /"`
set vd=`pwd | awk -F/ '{print substr($NF,2,3)}'`
set vs=`date -j -v+${vd}d 121801002020 "+%b %e" | sed "s/  / /"`
# goto Ave
echo "" > infecAve
foreach d (MyResult_??)
cd $d
#
set n=0
foreach f (indexes_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
touch XX.csv
foreach f (indexes_*.csv)
  awk -F, '$1>0{x+=$2+$3;n++;if($1%4==0){printf "\t%.4f\n",x/n/'$pop'.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/4;i<$1/4;i++) print "\t0"}' >> X$f
  lam XX.csv X$f > X2.csv
  rm XX.csv X$f; mv X2.csv XX.csv
end
awk '{printf "%.2f%s\n",NR/4.,$0}' XX.csv > infected
rm XX.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.4f\n",s/(NF-1)}\
END{for(i=NR;i<=1024;i++) print "\t0"}' infected > infecAve
#
set nn=`echo $d | cut -d_ -f2`
set vr=`expr $nn \* 2 + 2`
set nf=`echo indexes_*.csv | awk '{print NF}'`
echo plot m$nn.svg 
gnuplot <<EOF > $dst/m$nn.svg
set terminal svg size 640 240
set label "Population size = ${pop}00\nReleasing date: $rs\nVaccination: $vs"\
 at screen .5,.85 center
unset key
set style data lines
set ylabel "infected (%)"
set xrange [:256]
set xtics ("Jan 7" 20, "Feb 7" 51, "Mar 7" 79, "Apr 1" 104,\
 "May 1" 134, "Jun 1" 165, "Jul 1" 195, "Aug 1" 226)
set arrow from 20,graph 0 to 20,graph 1 nohead lc rgbcolor "red"
set arrow from ${rd},graph 0 to ${rd},graph 1 nohead lc rgbcolor "#008800"
set arrow from ${vd},graph 0 to ${vd},graph 1 nohead lc rgbcolor "#660088"
set label "${vr}%" at graph .025,.85
plot for [i=2:(${nf}+1)] 'infected' using 1:i
EOF
lam ../infecAve infecAve > ../infecAve2
rm infecAve
cd ..
mv -f infecAve2 infecAve
end
#
echo -n "-" > infected
foreach d (MyResult_??)
  echo $d | cut -d_ -f2 | awk '{printf "\t\"%.1f%%\"",($1*2+2)/10}' >> infected
end
echo "" >> infected
awk '{printf "%.2f%s\n",NR/4.,$0}' infecAve >> infected
rm infecAve
Ave:
set nf=`echo MyResult_?? | awk '{print NF}'`
setenv LANG ja_JP.UTF-8
echo plot Average.svg
gnuplot <<EOF > $dst/Average.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00\nReleasing date: $rs\nVaccination: $vs"\
 at screen .5,.85 center
set label "→ restriction" at 20,graph .15
set label "→ release" at ${rd},graph .5
set label "→ vaccine" at ${vd},graph .4
set key right title "perform rate"
set style data lines
set ylabel "infected (%)"
set xrange [:256]
set xtics ("Jan 7" 20, "Feb 7" 51, "Mar 7" 79, "Apr 1" 104,\
 "May 1" 134, "Jun 1" 165, "Jul 1" 195, "Aug 1" 226)
set arrow from 20,graph 0 to 20,graph 1 nohead lc rgbcolor "red"
set arrow from ${rd},graph 0 to ${rd},graph .55 nohead lc rgbcolor "#008800"
set arrow from ${vd},graph 0 to ${vd},graph .45 nohead lc rgbcolor "#660088"
plot for [i=1:${nf}] 'infected' using 1:i+1 \
 title columnhead lc rgb hsv2rgb(i*.8/${nf},1,.8)
EOF
echo plot Average2.svg
gnuplot <<EOF > $dst/Average2.svg 
set terminal svg size 640 300
set label "Population size = ${pop}00\nReleasing date: $rs\nVaccination: $vs"\
 at screen .5,.85 center
set label "→ release" at ${rd},graph .8
set label "→ vaccine" at ${vd},graph .8
set key right title "perform rate"
set style data lines
set ylabel "infected (%)"
set xrange [79:256]
set yrange [:0.04]
set xtics ("Jan 7" 20, "Feb 7" 51, "Mar 7" 79, "Apr 1" 104,\
 "May 1" 134, "Jun 1" 165, "Jul 1" 195, "Aug 1" 226)
set arrow from ${rd},graph 0 to ${rd},graph 1 nohead lc rgbcolor "#008800"
set arrow from ${vd},graph 0 to ${vd},graph 1 nohead lc rgbcolor "#660088"
plot for [i=1:${nf}] 'infected' using 1:i+1 \
 title columnhead lc rgb hsv2rgb(i*.8/${nf},1,.8)
EOF
open $dst