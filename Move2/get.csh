#! /bin/csh
set n=0
foreach job (z50jwTnoyO4 6OoGygVG9tZ JdDcX7Vk6dD uBROF5VxyZB taXCPNnUGwo 4bzmJpVOrVn\
 dKwIePVJvab 3HZRtdVe23r HRq6pnn6jUQ A6fTHrVpRXZ Mrko9xnuVBT)
set fn=`printf "MyResult%02d\n" $n`
curl -O -J -s http://simepi.intlab.soka.ac.jp/getJobResults\?job=${job}\&save=$fn
if (-f ${fn}.zip) then
  unzip -q $fn
  rm ${fn}.zip
endif
@ n = $n + 1
end