#! /bin/bash
for d in R_*_??; do
m=`echo $d | awk -F_ '{print $2}'`
r=`echo $d | awk -F_ '{printf "MyResult_%02d\n",$3%10}'`
if [ ! -d $r ]; then mkdir $r; b=0
else b=`(cd $r; echo index*.csv | awk '{print NF}')`; fi
cd $d
n=0
nx=1
for n in `echo index*.csv | awk -F. '{split($1,a,"_");print a[2]}' | sort -n`; do
#   if [ -f daily_$n.csv -a -f distribution_$n.csv ]; then
  if [ -f daily_$n.csv ]; then
    if [ $n -gt $nx ]; then
#       for h in indexes daily distribution; do mv ${h}_$n.csv ${h}_$nx.csv;echo $h $n $nx; done
      for h in indexes daily; do mv ${h}_$n.csv ${h}_$nx.csv;echo $h $n $nx; done
    fi
    nx=`expr $nx + 1`
  fi
done
for f in *.csv; do \
mv $f ../$r/`echo $f | awk -F. '{split($1,a,"_");printf "%s_%d.csv\n",a[1],a[2]+'$b'}'`
done
cd ..
echo $r `(cd $r; echo *.csv) | wc -w`
done
rm -rf R_*_??
