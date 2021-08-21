#! /bin/bash
for d in V???/MyResult_??; do
  cd $d
  nn=0
  for n in `echo index*.csv | \
  awk '{for(i=1;i<=NF;i++){split($i,a,".");split(a[1],b,"_");print b[2]}}' | sort -n`; do
    nn=`expr $nn + 1`
    if [ $n -gt $nn ]; then
      for h in indexes daily distribution; do mv ${h}_$n.csv ${h}_$nn.csv; done
    fi
  done
  echo $d $nn
  cd ../..
done
