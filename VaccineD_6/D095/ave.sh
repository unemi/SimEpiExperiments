#! /bin/bash
stat () {
local n=0
local s=0
local nn=0
for f in $1_*.csv; do
  nn=`tail -1 $f | cut -d, -f1`
  if [ $n -lt $nn ]; then n=$nn; fi
  nn=`head -2 $f | tail -1 | cut -d, -f1`
  if [ $s -lt $nn ]; then s=$nn; fi
done
rm -f ave.csv
for ((x=$s;x<=$n;x+=$s)); do echo $x >> ave.csv; done
for f in `ls $1_*.csv | awk -F. '{split($1,a,"_");print a[2]}' | sort -n`; do
  awk -F, 'NR>1{if($1%'$s'==0){printf ",%d\n",'$2';nn=$1}}\
  END{for(i=nn;i<'$n';i+='$s')print ",0"}' $1_$f.csv > /tmp/ave$$
  lam ave.csv /tmp/ave$$ > aveX.csv
  mv aveX.csv ave.csv
done
rm /tmp/ave$$
# local ss=`echo $n $s | awk '{print int($1/$2/2)*$2}'`
local ss=0
awk -F, '{x=0;x2=0;for(i=2;i<=NF;i++){x+=$i;x2+=$i*$i}\
    m=x/(NF-1);s=sqrt(x2/(NF-1)-m*m);printf "%s,%.6f,%.6f\n",$0,m,m+s;\
  if($1>'$ss'){nn++;\
  for(i=2;i<=NF;i++){d[i]+=m-$i;d2[i]+=(m-$i)*(m-$i)*$1/'$n';ds2[i]+=(m+s-$i)*(m+s-$i)}}}\
  END{printf "D";for(i=2;i<=NF;i++)printf ",%.6f",d[i]/nn;print "";\
  printf "D2";for(i=2;i<=NF;i++)printf ",%.6f",d2[i]/nn;print "";\
  printf "DS";for(i=2;i<=NF;i++)printf ",%.6f",ds2[i]/nn;print ""}' ave.csv > ave$3.csv
rm ave.csv
tail -3 ave$3.csv | awk -F, \
'NR==1{ju=2;jl=2;vu=$2;vl=$2;\
for(i=3;i<=NF;i++){if(vl>$i){vl=$i;jl=i}else if(vu<$i){vu=$i;ju=i}}\
printf "worst'$3' %d %.6f\nbest'$3' %d %.6f\n",jl-1,vl,ju-1,vu}\
NR==2{j=2;v=$2;for(i=3;i<=NF;i++)if(v>$i){v=$i;j=i}\
printf "middle'$3' %d %.6f\n",j-1,v}\
NR==3{j=2;v=$2;for(i=3;i<=NF;i++)if(v>$i){v=$i;j=i}\
printf "plusSingma'$3' %d %.6f\n",j-1,v}' >> aveResult.txt
}

deliv () {
local x=`awk '/'$1'/{print $2}' aveResult.txt`
if [ $x -le 3 ]; then m="simepi2"; n=$x
elif [ $x -gt 35 ]; then m="simepi"; n=`expr $x - 35`
else m="simepiM0"`expr \( $x - 4 \) / 4`; n=`expr \( $x - 4 \) % 4 + 1`
fi
local ln=`echo $2 | awk -F_ '{printf "%d\n",$2+1}'`
echo ./dlvState.sh $m `awk 'NR=='$ln'{print}' ../jobID_$m`_$n \
`pwd | awk -F/ '{print $(NF-1)}'`_$3
}

if [ ! -d MyResult_00 ]; then echo "MyResult_00 does not exist."; exit; fi
cd MyResult_00
rm -f aveResult.txt
stat indexes '$2+$3' IN
stat daily '$2' TP
cat aveResult.txt
deliv middleIN $d fair
deliv plusSingmaIN $d worse
echo "------"
mv ave* ..
cd ..
