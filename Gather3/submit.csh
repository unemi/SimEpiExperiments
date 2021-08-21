#! /bin/csh
rm -f jobID
foreach x (2 4 6 8 12 14 16 18 22 24 26 28 32 34 36 38)
echo $x
curl http://simepi.intlab.soka.ac.jp/submitJob -s --crlf -d @- >>jobID <<EOF
job={"stopAt":200,"n":10,
"params":{"populationSize":90000,"worldSize":1080,"mesh":54,"initialInfected":36,
	"gatheringFrequency":${x},
	"immunity":[400,600,500]},
"out":[
	"asymptomatic","symptomatic","recovered","died",
	"dailyTestPositive","dailyTestNegative"]}
EOF
echo "" >>jobID
end
