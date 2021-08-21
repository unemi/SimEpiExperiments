#! /bin/sh
if [ -z $1 ]; then echo "Usage: $0 <machine_name>"; exit; fi
jj=jobID_$1
if [ ! -f $jj ]; then echo "$jj does not exist."; exit; fi
m=`echo $jj | cut -d_ -f2`
i=0
for job in `cat $jj`; do
fn=`printf "R_${m}_%02d\n" $i`
curl -O -J -s http://$m.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
rt=$?
if [ $rt = 0 ]; then
	if [ -f ${fn}.zip ]; then
	  unzip -q $fn
	  rm ${fn}.zip
	  (cd $fn; echo *.csv | awk '{printf "'$fn' %d\n",NF}')
	else
	  echo "Could not get $fn.zip"
	fi
else
  echo "curl error ($rt) for $job"
fi
i=$(($i+1))
done
