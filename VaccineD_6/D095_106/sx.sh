#! /bin/bash
m=localhost
pf=":8000"
nn=4
for gf in 4 5; do
curl http://$m$pf/submitJob -d @- <<EOF
job={"stopAt":106,"n":$nn,
"loadState":"D095_360K",
"params":{"gatheringFrequency":$gf},
"out":["asymptomatic","symptomatic",
"dailyTestPositive","dailyTestNegative",
"saveState"]}
EOF
echo ""
done
