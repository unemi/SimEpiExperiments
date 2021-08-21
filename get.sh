#! /bin/sh
n=0
if [ -n "$1" ]; then n=$1; fi
for jj in jobID_*; do
m=`echo $jj | cut -d_ -f2`
if [ $n -gt 0 ]; then echo $m; fi
i=0
for job in `cat $jj`; do
fn=`printf "R_${m}_%02d\n" $i`
curl -O -J -s http://$m.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
rt=$?
if [ $rt = 0 ]; then
	if [ -f ${fn}.zip ]; then
	  unzip -q $fn
	  rm ${fn}.zip
	  nn=`(cd $fn; echo *.csv | awk '{print NF}')`
	  if [ $n = 0 ]; then echo "$fn $nn"
	  elif [ ! $nn -eq $n ]; then echo "$fn $nn (but not $n)"; fi
	else
	  echo "Could not get $fn.zip"
	fi
else
  echo "curl error ($rt) for $job"
fi
i=$(($i+1))
done
done
