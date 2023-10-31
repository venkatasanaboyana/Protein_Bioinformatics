#!/usr/bash
#This script was made to divide hmmer jobs into a 50jobs each
#To run this script succesfully, we need faa_path.txt (which containts the path to all
#the metagenomes and also a template_script.sh
num_jobs=$1; 

count=0;
while mapfile -t -n $num_jobs ary && ((${#ary[@]})); 
do
    ((count++)); 
    mkdir meta-$count; 
    name="meta-$count"; 
    sed "s/.*#$ -N/#$ -N ${name}/" hmmer_jobs.sh > temp1    
    start=1; 
    for i in $(seq 1 $num_jobs)
    do
	j=$((i-1));
	db=${ary[$j]}; 
	sed -e "/num_jobs=/a\\db$i='$db'" temp1 > temp2
	#sed "s|db$i=|db$i='$db'|g" temp1 > temp2;
	mv temp2 temp1  
    done
    mv temp1 meta-$count/job_$count.job
done < faa_path.txt
