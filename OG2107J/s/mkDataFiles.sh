#! /bin/bash
dirName=`pwd | awk -F/ '{print $NF}'`
mk=`echo $dirName | awk -F_ '{print $1}'`
pop=10000
dtDir=MyResult_00
spd=12 # steps per day
tl=0
for f in $dtDir/daily_*.csv; do
 x=`awk -F, 'END{print $1}' $f`
 if [ $tl -lt $x ]; then tl=$x; fi
done
#
makeDataFile () {
awk -F, '$1>0{x+='$3';n++;if($1%'$4'==0)\
{z=x/n;k=$1/'$4';v[k]+=z;v2[k]+=z*z;nv[$1/'$4']++;x=0;n=0}}\
 END{for(i=1;nv[i]>0;i++){e=v[i]/nv[i]/'$pop'.;\
 vv=(v2[i]-v[i]*v[i]/nv[i])/nv[i];if(vv<0)s=0;else s=sqrt(vv)/'$pop'.;\
 printf "%.'$5'f %.'$5'f\n",e,s}}' $2_*.csv > ../$1.csv
echo $1.csv
}
cd $dtDir
for f in daily_*.csv; do
awk -F, 'NR==1{i=0;for(j=2;j<=NF;j++){s[j]=0;for(k=0;k<7;k++)q[j*7+k]=0}print}\
$1>0{if(n<7)n++;for(j=2;j<=NF;j++){k=j*7+i;s[j]+=$j-q[k];q[k]=$j}i=(i+1)%7;\
if(n>=4){printf "%s",$1-3;for(j=2;j<=NF;j++){printf ",%.4f",s[j]/n}print ""}}\
END{for(a=1;a<=3;a++){printf "%d",$1-3+a;n--;\
for(j=2;j<=NF;j++){s[j]-=q[j*7+i];printf ",%.4f",s[j]/n}print ""}}'\
 $f > weekly_`echo $f | awk -F_ '{print $2}'`
done
makeDataFile IN indexes '$2+$3' $spd 6
makeDataFile TP weekly '$2' 1 8
makeDataFile VC indexes '$6' $spd 6
makeDataFile AP indexes '$2-$7' $spd 8
makeDataFile SV severity '($NF+$(NF-1))/3' 1 12
cd ..
#
