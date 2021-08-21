#! /bin/csh
cd 2
foreach d (MyResult*)
cd $d
foreach f (*.csv)
mv $f ../../$d/`echo $f | awk -F_ '{split($2,x,".");printf "%s_%d.csv\n",$1,x[1]+10}'`
end
cd ..
end