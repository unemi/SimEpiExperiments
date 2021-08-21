#! /bin/csh
set n=0
foreach job (`cat jobID`)
set fn=`printf "MyResult%02d\n" $n`
curl -O -J -s http://simepi.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if (-f ${fn}.zip) then
  unzip -q $fn
  rm ${fn}.zip
endif
@ n = $n + 1
end