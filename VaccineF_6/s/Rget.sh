#! /bin/sh
for jj in jobIDR_*; do
m=`echo $jj | cut -d_ -f2`
n=`echo $jj | cut -d_ -f3`
job=`cat $jj`
fn="R_${m}_${n}"
curl -O -J -s http://$m.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
rt=$?
if [ $rt = 0 ]; then
	if [ -f ${fn}.zip ]; then
	  unzip -q $fn
	  rm ${fn}.zip
	  nn=`(cd $fn; echo *.csv | awk '{print (NF==1&&length($1)==5)? 0 : NF}')`
	  if [ $nn = 0 ]; then msg="$m $job has no result for $fn."
	    echo $msg; echo $msg >> FailedTasksX.txt; rmdir $fn
	  else echo "$fn $nn"; fi
	else
	  echo "Could not get $fn.zip"
	fi
else
  echo "curl error ($rt) for $job"
fi
done
