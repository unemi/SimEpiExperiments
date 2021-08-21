#! /bin/csh
set n=1
foreach job (E1dbXU5txM2 SzyFsD5OrlQ WUAQIl9Iok5 awuDPr9uVYH)
set fn=`printf "MyResult%02d\n" $n`
curl -O -J -s http://simepi.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if (-f ${fn}.zip) then
  unzip -q $fn
  rm ${fn}.zip
endif
@ n = $n + 1
end