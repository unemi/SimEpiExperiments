#! /bin/bash
if [ "$1" = "" ]; then dirs=.; else dirs="$*"; fi
for a in TP IN SV AP; do
for d in $dirs; do
  cd $d
  if [ -f $a.csv ]; then
    echo -n $d $a" " >> /tmp/pk$$
    awk '{if(v<$1){v=$1;d=NR}}\
      END{printf "%d %f\n",d,v}' $a.csv >> /tmp/pk$$
  fi
  cd ..
done
done
for dd in `cut -d\  -f3 /tmp/pk$$ | sort | uniq`; do
  echo -n $dd >> /tmp/pd$$
  date -j -v+${dd}d 121601002020 "+ %b月 %e日" >> /tmp/pd$$
done
awk 'NF==3{dt[$1]=$2 $3}\
NF==4{split($1,a,"_");\
  fmt=($2=="TP")?"%.4f":($2=="SV")?"%.5f":"%.3f";p=sprintf(fmt,$4);\
  printf "<tr><th class=rr>%d%%<td class=dt>%s<td>%s%%<td>%'\''d人</tr>\n",\
  a[2],dt[$3],p,$4*139600}' /tmp/pd$$ /tmp/pk$$
rm -f /tmp/pk$$ /tmp/pd$$