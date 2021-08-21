#! /bin/sh
awk 'BEGIN{m=0;A=0;print "job={\n\"params\":{\"populationSize\":\$s"}
{if(m==0&&NR>1){
 if($0~/populationSize/)ps=$3;else if($0~/mesh/)ms=$3;else if($0~/worldSize/)ws=$3;
 else if($0=="}"){print;m=1;print "\"scenario\":["}
 else if($NF=="["){s=$0;A=1}else if(A==0)print;else if($1~/^\]/){print s $1;A=0}else s=s $1}
 else if(length($0)>1){
 if($NF=="["){s=$0;A=1}else if(A==0)print;
  else if($1~/^\]/){print s $1;A=0}
  else if($0~/\"/){split($0,a,"\"");s=s "\"" a[2] "\"" a[3]}
  else s=s $1}}
 END{printf "]}\n# populationSize=%smesh=%sworldSize=%s\n",ps,ms,ws}' | \
sed '/ : /s//:/
/>=/s//%3E%3D/'