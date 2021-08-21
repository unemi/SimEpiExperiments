#! /bin/bash
rm -f d_*.csv
for va in 20 40; do for prs in 02 04; do
for nd in V_[0-9]_136_${prs}_${va}; do if [ -d $nd ]; then
cd $nd
rm -f died.csv
for r in MyResult_??; do if [ -d $r ]; then
  cd $r
  rm -f died
  for f in indexes_*.csv; do awk -F, '$1==136*12{a=$5}\
  END{print $5-a}' $f >> died; done
  awk '{s+=$1;s2+=$1*$1}\
  END{printf "%.3f\t%.3f\n",s/NR,sqrt((s2-s*s/NR)/NR)}' died >> ../died.csv
  rm -f died
  cd ..
  else echo "No $r under `pwd`"
  fi
done
for n in 1 2 3; do awk 'NR=='$n'{print}' died.csv >> ../d_${prs}_${va}_$n.csv; done
cd ..
else echo "No $nd under `pwd`"
fi
done;done;done
#
# for f in d_*.csv; do
#   
# done
# rm -f d_*.csv