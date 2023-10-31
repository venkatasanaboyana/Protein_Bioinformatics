#!/bin/bash

#This script sends the job scripts to argon processors. 
#Submits any job ending with .job extension and all at a time.
#ls * > list_jobs.txt !make sure list_jobs.txt has entries that 
#you are intending to submit the jobs for. 
find meta* -maxdepth 1 -type d > list_jobs.txt
echo Uniref100 >> list_jobs.txt 

for i in $(cat list_jobs.txt)
do
	cd $i
	cp ../query.hmm .
	qsub *.job
	cd ..
done
