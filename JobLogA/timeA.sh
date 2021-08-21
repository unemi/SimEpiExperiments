#! /bin/sh
# cat log_0080_* log_0080.txt | \
cat log.txt | \
awk '/Trial .* of job .* started/{j=$4 "," $7;s[j]=$1 "," $2}\
/Trial .* of job .* finished as /{j=$4 "," $7;\
if(s[j]!=""){printf "%s %s %s,%s %s\n",j,s[j],$1,$2,$10;s[j]=""}}' > /tmp/A$$
n=`awk 'END{print NR}' /tmp/A$$`
echo $n entries in /tmp/A$$
for ((i=1;i<=$n;i++)) do \
awk 'NR=='$i'{print;exit}' /tmp/A$$ > /tmp/B$$
date -j -f "%Y/%m/%d,%H:%M:%S" `awk '{print $2}' /tmp/B$$` "+%s" > /tmp/S$$
date -j -f "%Y/%m/%d,%H:%M:%S" `awk '{print $3}' /tmp/B$$` "+%s" >> /tmp/S$$
cat /tmp/S$$ /tmp/B$$ | awk 'NR==1{s=$1}\
NR==2{t=$1-s}\
NR==3{printf "%s %d %s\n",$1,t,$4}' >> /tmp/X$$
done
rm /tmp/A$$ /tmp/B$$ /tmp/S$$
