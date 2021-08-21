#! /bin/bash
LANG=C date
for m in simepi simepi2 simepiM0{0..7}; do
  echo $m > /tmp/w$$
  s=`curl -s http://$m.intlab.soka.ac.jp/sysInfo`
  echo $s | jq '.["rss"]' >> /tmp/w$$
  echo $s | jq '.["memsize"]' >> /tmp/w$$
  echo $s | jq '.["loadaverage"] | .[0,1,2]' >> /tmp/w$$
  echo $s | jq '.["model"]' | awk -F\" '{print $2}' >> /tmp/w$$
  echo $s | jq '.["ncpu"]' >> /tmp/w$$
  echo $s | jq '.["thermalState"]' >> /tmp/w$$
  awk '{a[NR]=$0}\
  END{printf "%9s %s(%d)T%d, rss %.3fG %5.2f%%, load average %6.3f %6.3f %6.3f\n",\
  a[1],a[7],a[8],a[9],a[2]/1024/1024/1024,a[2]/a[3]*100,a[4],a[5],a[6]}' /tmp/w$$
  rm /tmp/w$$
done
