#! /bin/bash
for f in jobID_*; do
	nn=`awk 'END{print NR}' $f`
  if [ $nn -eq 1 ]; then cat $f 1/$f | awk '{if(NR==1)a=$0;\
    else{print;if(NR==2)print a}}' > x
  else cat $f 1/$f | awk 'BEGIN{i=1}\
    {if(NR<='$nn')a[NR]=$0;\
     else{print;if((NR-'$nn')%3==1)print a[i++]}}' > x
  fi
  mv -f x $f
done