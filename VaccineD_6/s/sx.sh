#! /bin/bash
m=localhost
pf=":8000"
nn=1
for gf in 5; do
curl http://$m$pf/submitJob -d @- <<EOF
job={"stopAt":106,"n":$nn,
"loadState":"D095_360K",
"params":{"gatheringFrequency":$gf,
"vaccinePerformRate":4,
"vaccinePriority":3,
"vaccineAntiRate":30},
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative"]}
EOF
echo ""
done
