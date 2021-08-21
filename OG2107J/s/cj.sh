#! /bin/bash
# for d in B116 B150 B199 B242; do
for d in B199 B242; do
cd $d
echo $d
./submit.sh
sleep 600
../../monitor.sh
cd ..
done