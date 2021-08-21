#! /bin/csh
set i=0
foreach job (`cat jobID`)
set fn=`printf "MyResult%02d\n" $i`
curl -O -J -s http://simepi.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if (-f ${fn}.zip) then
  unzip -q $fn
  rm ${fn}.zip
endif
@ i = $i + 10
end