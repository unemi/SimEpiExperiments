#! /bin/bash
curl http://localhost:8000/submitJob -s -d @- <<EOF
job={"stopAt":50,"n":1,
"scenario":[
  "days %3E%3D 20",["vaccinePriority",2]
],
"out":["asymptomatic","symptomatic","recovered","died","vaccinated",
"quarantineAsym","quarantineSymp",
"dailyTestPositive","dailyTestNegative"]}
EOF
echo ""
