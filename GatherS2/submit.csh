#! /bin/csh
rm -f jobID
foreach x (0 1 2 3 4 5 6 7 8 9 10)
echo $x
curl http://simepi.intlab.soka.ac.jp/submitJob -s -d @- >>jobID <<EOF
job={"stopAt":200,"n":10,
"params":{"populationSize":40000,"worldSize":720,"mesh":36,"initialInfected":16,
	"gatheringSize":`echo $x | awk '{printf "[%d,%d,%d]",\$1,\$1*4,\$1*2}'`,
	"immunity":[400,600,500]},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative"]}
EOF
echo "" >>jobID
end
