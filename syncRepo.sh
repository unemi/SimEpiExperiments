#! /bin/bash
if [ -f syncTouchRepo ]; then opt="--newer-mtime-than syncTouchRepo"
else opt=""
fi
COPYFILE_DISABLE=1 tar -cpf - $opt *.{csh,sh} */*.{csh,sh} */*/*.{csh,sh} | \
(cd ~/Program/SimEpidemic/ExGitHub/SimEpiExperiments; tar -xpf -)
touch syncTouchRepo
