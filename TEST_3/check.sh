#! /bin/bash
LANG=C date
for m in simepi2 ; do \
curl http://$m.intlab.soka.ac.jp/getJobQueueStatus
echo ""
for j in `cat jobID_simepi2`; do echo -n $j" "
curl http://$m.intlab.soka.ac.jp/getJobStatus?job=$j
echo ""
done
done
