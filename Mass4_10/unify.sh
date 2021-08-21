#! /bin/bash
for m in simepi simepi2; do \
for d in R_${m}_??; do \
r=`echo $d | awk -F_ '{printf "MyResult_%02d\n",$3}'`
if [ ! -d $r ]; then mkdir $r; b=0; else b=5; fi
cd $d
for f in *.csv; do \
mv $f ../$r/`echo $f | awk -F. '{split($1,a,"_");printf "%s_%d.csv\n",a[1],a[2]+'$b'}'`
done
cd ..
done
done
