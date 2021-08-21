#! /bin/csh
set nl=(2 4 6 8 12 14 16 18 22 24 26 28 32 34 36 38)
set i=1
foreach job (`cat jobID`)
set fn=`printf "MyResult%02d\n" $nl[$i]`
curl -O -J -s http://simepi.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if (-f ${fn}.zip) then
  unzip -q $fn
  rm ${fn}.zip
endif
@ i = $i + 1
end