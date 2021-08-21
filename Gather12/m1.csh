#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/Gather2"
set pop=400
foreach d (MyResult??)
if (! -d $dst) mkdir -p $dst
cd $d
#
set n=0
foreach f (indexes_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
foreach f (indexes_*.csv)
  awk -F, '$1>0{x+=$2+$3;n++;if($1%4==0){printf "\t%.2f\n",x/n/'$pop'.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for(i=$2/4;i<$1/4;i++) print "\t0"}' >> X$f
end
lam X*.csv | awk '{printf "%.2f%s\n",NR/4.,$0}' > infected
rm X*.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.2f\n",s/(NF-1)}\
END{for(i=NR;i<=800;i++) print "\t0"}' infected > infecAve
#
set nn=`echo $d | cut -c9-`
gnuplot -c ../m.gp `echo $nn | awk '{printf "%d\n",$1}'` > $dst/m$nn.svg 
cd ..
end
lam MyResult*/infecAve | awk '{printf "%.2f%s\n",NR/4.,$0}' > infected
rm MyResult*/infecAve
gnuplot -c m.gp -1 > $dst/Average.svg 
