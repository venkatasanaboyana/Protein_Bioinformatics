#!/bin/bash

./QUARK_SUBMISSION.pl $1 $2 $3 > QUARK_SUBMISSION_CONTENT;

JOB_ID=`grep "After" QUARK_SUBMISSION_CONTENT | awk '{print $4}'`
time_check=1; 
filename=$(echo "$1" | rev | cut -c 7- | rev);
while true
do
	`wget https://zhanglab.ccmb.med.umich.edu/QUARK/output/$JOB_ID/ -q -O - > HTML_QUARK`;
	grep -i "TM-score" HTML_QUARK > checked; 
	if [ -s checked ] 
	then 
	        echo $JOB_ID QUARK JOB is finished after $time_check hours
                echo downloading the structure..
                `wget https://zhanglab.ccmb.med.umich.edu/QUARK/output/$JOB_ID/model1.pdb -O $filename.pdb`;
		break;		
	else
		echo $JOB_ID QUARK JOB is running..check after $time_check.0hr
		time_check=$((time_check+1)); 
		sleep 1h;	
        fi
done

	sleep 5m; 
		
