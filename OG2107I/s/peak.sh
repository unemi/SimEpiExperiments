#! /bin/bash
for a in TP IN; do
for d in E_??_???; do
  cd $d
  echo -n $d $a" " >> /tmp/pk$$
  awk '$1>0{if(v<$2){v=$2;d=$1}}\
  END{printf "%d %f\n",d,v}' $a.csv >> /tmp/pk$$
  cd ..
done
done
for dd in `cut -d\  -f3 /tmp/pk$$ | sort | uniq`; do
  echo -n $dd >> /tmp/pd$$
  date -j -v+${dd}d 121601002020 "+ %b月 %e日" >> /tmp/pd$$
done
awk 'NF==3{dt[$1]=$2 $3}\
NF==4{split($1,a,"_");if(a[3]==240){dd=dt[$3];vv=$4} else {\
  fmt=($2=="TP")?"%.4f":"%.3f";p1=sprintf(fmt,vv);p2=sprintf(fmt,$4);\
  printf "<tr><th class=rr>%d%%<td class=dt>%s<td>%s%%<td>%'\''d人<td class=dt>%s<td>%s%%<td>%'\''d人</tr>\n",\
  a[2],dd,p1,vv*139000,dt[$3],p2,$4*139000}}' /tmp/pd$$ /tmp/pk$$
rm -f /tmp/pk$$ /tmp/pd$$