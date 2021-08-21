#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/"`pwd | awk -F/ '{print $NF}'`
if (! -d $dst) mkdir -p $dst
set pop=`pwd | awk '{n=substr($0,length($0),1);printf "%d\n",n*n*100}'`
echo "" > infects
foreach d (MyResult??)
cd $d
#
set nn=`echo $d | cut -c9-`
set nf=`echo indexes_*.csv | awk '{print NF}'`
rm -f X
foreach f (distribution_*.csv)
  awk -F, 'NR>1{t+=$5;n[$1]=$5*100;if($5>0)m=NR-1}\
  END{printf "%.2f,%.2f,%.2f,%d\n",n[0]/t,n[1]/t,n[2]/t,m}' $f >> X
end
awk -F, '{for(i=1;i<=4;i++){s[i]+=$i;s2[i]+=$i*$i}}\
END{printf "%d",'$nn';for(i=1;i<=4;i++)printf "\t%.2f\t%.2f",\
  s[i]/'$nf',(s2[i]-s[i]*s[i]/'$nf')/'$nf';print ""}' X >> ../infects
rm X
#
cd ..
end
#
set nf=`echo MyResult?? | awk '{print NF}'`
gnuplot <<EOF > $dst/Infects.svg 
set terminal svg size 640 360
set label "Population size = ${pop}00" at screen .5,.9 center
set style data boxerrorbars
set boxwidth .2
set style fill solid .75
set key left
set xlabel "test rate (%)"
set ylabel "% in total infected"
set y2label "maximum spread"
set xtics scale 0 1
set ytics nomirror
set y2tics 10
set xrange [-.5:10.5]
set yrange [0:*]
set y2range [0:*]
plot 'infects' using (\$1-.3):2:3 title "infects none", '' using (\$1-.1):4:5 title "one",\
 '' using (\$1+.1):6:7 title "two", "" using (\$1+.3):8:9 title "max spread" axis x1y2
EOF