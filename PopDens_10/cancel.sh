#! /bin/bash
for j in `cat jobID`; do \
echo $j
curl http://simepi2.intlab.soka.ac.jp/stopJob?job=$j
echo ""
done
