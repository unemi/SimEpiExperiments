#! /bin/bash
for a in 081 088 095; do
for b in 106 136; do
  cd ../V_G${a}_${b}
  for c in fair worse; do
  for d in 01 02 04 08 16 A; do
    mv in_${c}_${d}_3.svg in_${c}_${d}_4.svg
    mv tp_${c}_${d}_3.svg tp_${c}_${d}_4.svg
    mv in_${c}_${d}_3_4.svg in_${c}_${d}_4_4.svg
    mv tp_${c}_${d}_3_02.svg tp_${c}_${d}_4_02.svg
  done
  done
done
done