#! /bin/bash
cd MyResult_00
awk -F, 'NR>1{print $1}' indexes_1.csv > ave.csv
for f in `ls indexes_*.csv | awk -F. '{split($1,a,"_");print a[2]}' | sort -n`; do
  awk -F, 'NR>1{printf ",%d\n",$2+$3}' indexes_$f.csv > /tmp/ave$$
  lam ave.csv /tmp/ave$$ > aveX.csv
  mv aveX.csv ave.csv
done
awk -F, '{x=0;for(i=2;i<=NF;i++)x+=$i;m=x/(NF-1);printf "%s,%.6f\n",$0,m;\
  for(i=2;i<=NF;i++){d[i]+=m-$i;d2[i]+=(m-$i)*(m-$i)}}\
  END{printf "D";for(i=2;i<=NF;i++)printf ",%.6f",d[i]/NR;print "";\
  printf "D2";for(i=2;i<=NF;i++)printf ",%.6f",d2[i]/NR;print ""}' ave.csv > aveY.csv
mv aveY.csv ../ave.csv
rm ave.csv
cd ..
tail -2 ave.csv | awk -F, \
'NR==1{ju=2;jl=2;vu=$2;vl=$2;\
for(i=3;i<=NF;i++){if(vl>$i){vl=$i;jl=i}else if(vu<$i){vu=$i;ju=i}}\
printf "worst %d %.6f\nbest %d %.6f\n",jl-1,vl,ju-1,vu}\
NR==2{j=2;v=$2;for(i=3;i<=NF;i++)if(v>$i){v=$i;j=i}\
printf "average %d %.6f\n",j-1,v}'
