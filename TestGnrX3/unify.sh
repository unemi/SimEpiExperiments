#! /bin/bash
for d in MyResult?? ; do \
for n in {1..10} ; do \
for f in daily distribution indexes ; do \
mv ../TestGnrY3/$d/${f}_$n.csv $d/${f}_$(($n+10)).csv
done
done
done
