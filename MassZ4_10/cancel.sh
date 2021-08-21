#! /bin/bash
for m in simepi simepi2; do \
for j in `cat jobID_$m`; do \
echo $j
curl http://$m.intlab.soka.ac.jp/stopJob?job=$j
echo " "$j" "$m
done
done