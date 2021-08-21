#! /bin/bash
for d in R_*_??; do \
r=`echo $d | awk -F_ '{printf "MyResult_%02d\n",$3}'`
if [ ! -d $r ]; then mkdir $r; b=0
else b=`(cd $r; echo index*.csv | awk '{k=0;\
for(i=1;i<=NF;i++){split($i,a,"_");split(a[2],b,".");if(k<b[1])k=b[1]}print k}')`; fi
cd $d
for f in *.csv; do \
mv $f ../$r/`echo $f | awk -F. '{split($1,a,"_");printf "%s_%d.csv\n",a[1],a[2]+'$b'}'`
done
cd ..
done
