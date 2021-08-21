#! /bin/csh
rm -f jobID
# foreach x (0 10 20 30 40 50 60 70 80 90 100)
foreach x (0)
echo $x
curl http://simepi.intlab.soka.ac.jp/submitJob -s --crlf -d @- >>jobID <<EOF
job={"stopAt":200,"n":10,
"params":{"populationSize":10000,"worldSize":360,"mesh":18,"initialInfected":4,
	"gatheringFrequency":${x},
	"immunity":[400,600,500]},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative"]}
EOF
echo "" >>jobID
end
