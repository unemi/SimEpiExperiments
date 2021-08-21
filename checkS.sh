#! /bin/bash
LANG=C date
for m in simepi simepi2 simepiM0{0..7}; do
  echo -n $m" "
  curl http://$m.intlab.soka.ac.jp/sysInfo
  echo ""
done
