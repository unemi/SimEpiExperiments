#! /bin/bash
LANG=C date
for m in simepi simepi2 simepiM0{0..7}; do
  echo -n $m" "
  curl -s http://$m.intlab.soka.ac.jp/getJobQueueStatus
  echo ""
done
