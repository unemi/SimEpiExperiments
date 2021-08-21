#! /bin/csh
set dst="~/Program/SimEpidemic/Documents/Figures/LongMove1"
foreach d (MyResult0??)
cd $d
#
set n=0
foreach f (indexes_*.csv)
  set nn=`tail -1 $f | cut -d, -f1`
  if ($n < $nn) set n=$nn
end
foreach f (indexes_*.csv)
  awk -F, '$1>0{x += $2+$3; n++; if ($1 % 8 == 0) {printf "\t%.2f\n",x/n/400.;x=0;n=0}}' $f > X$f
  echo "$n "`tail -1 $f | cut -d, -f1` | awk '{for (i = $2/8; i < $1/8; i++) print "\t0"}' >> X$f
end
lam X*_??.csv | lam X*_?.csv - | awk '{printf "%.2f%s\n",NR/2.,$0}' > infected
rm X*.csv
awk '{s=0;for(i=2;i<=NF;i++)s+=$i;printf "\t%.2f\n",s/(NF-1)}\
END{for(i=NR;i<=800;i++) print "\t0"}' infected > infecAve
#
set nn=`echo $d | cut -c9-`
gnuplot -c ../m2.gp `echo $nn | awk '{printf "%.1f\n",$1/10.}'` > $dst/m$nn.svg 
cd ..
end
lam MyResult0??/infecAve | awk '{printf "%.2f%s\n",NR/2.,$0}' > infected
rm MyResult0??/infecAve
gnuplot -c m2.gp -1 > $dst/Average2.svg 
