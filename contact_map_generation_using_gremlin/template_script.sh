#!/bin/bash

##
#$ -S /bin/bash
##
#### This is an example submission script.
#### The lines that begin with `#$` are used
#### as arguments to qsub, while lines that
#### start with just `##` are comments
##
#### The below lines determines how many CPUs
#### your job will request. Only set it higher 
#### if you need the additional memory
####
#### The following line requests mulitple nodes
#### X threads per node (cpn) followed by the total
####$ -pe 64cpn 64
#### The following line requests a single node
#### with X number of threads
#$ -pe smp
#### The following line request a type of cpu
####$ -l cpu_arch=skylake_gold
#### The below lines requests GPUs
####
####$ -l ngpus=4
####$ -l gpu_1080ti=true
#### If your job requires a specific amount of
#### memory then use mem_XG for the amount of
#### memory you want on a machine (192, 256, etc.)
###$ -l mem_128G
##
#### The below option determines which queues 
#### your job is submitted to. Multiple can be
#### passed if separated by a comma
#### The elcock queue is called FERBIN
#### Some other queues are UI, UI-HM, CCOM
#$ -q 
##
#### The below option tells the compute node to 
#### begin execution from the same directory as
#### where you run the qsub. Otherwise, it is 
#### executed from '~/' -- which is where your
#### log file will end up. 
#$ -cwd
##
#### The following options all deal with making
#### sure your log file is in the correct format
#$ -j y
#$ -o $JOB_NAME.log 
#$ -ckpt user
#### The next options deal with email you when
#### your job is done.
####$ -M zachary-wehrspan@uiowa.edu
####$ -m e
##################
## DON'T FORGET ##
##  TO SET THE  ## 
##   JOB NAME   ##
##################
#$ -N

#### to submit the job:
#### $ qsub file.job

#### The below lines print the date to the log
#### and then store it as a variable
date
start=`date +%s`

########################################
## Put the commands you are executing ##
## inside of the " " on the next line ##
## so they will be printed to the log ##
########################################
CPU=
num_jobs=
uniprot=
CMD="
filepath=`pwd`;
mkdir -p /localscratch/Users/sanaboyana/meta_jobs/$uniprot/$JOB_NAME
for i in $(seq 1 $num_jobs)
do
        if [ ! -s all_msa${i}.txt ]
        then
		cd /localscratch/Users/sanaboyana/meta_jobs/$uniprot/$JOB_NAME	
		eval cp \${db${i}} temp.faa
		cp $filepath/query.hmm .
		#eval function helps to use a variable reference "inside" another variable
                hmmsearch -A all_msa${i}.sto -T 27 --cpu $CPU query.hmm temp.faa 
                echo FINISHED > all_msa${i}.txt
		cp all_msa${i}.sto all_msa${i}.txt $filepath;
		cd $filepath		
        fi
done
"


#### The below commands prints the text you
#### assigned to the CMD variable to the log
echo "**************************************"
echo "commands=$CMD"
echo "**************************************"

########################################
## Put the commands you are executing ##
##  in the lines below this comment,  ##
##   so they are actually  executed   ##
########################################

filepath=`pwd`;
mkdir -p /localscratch/Users/sanaboyana/meta_jobs/$uniprot/$JOB_NAME
for i in $(seq 1 $num_jobs)
do
        if [ ! -s all_msa${i}.txt ]
        then
                cd /localscratch/Users/sanaboyana/meta_jobs/$uniprot/$JOB_NAME
                eval cp \${db${i}} temp.faa
                cp $filepath/query.hmm .
		#eval function helps to use a variable reference "inside" another variable
                hmmsearch -A all_msa${i}.sto -T 27 --cpu $CPU query.hmm temp.faa
                echo FINISHED > all_msa${i}.txt
                cp all_msa${i}.sto all_msa${i}.txt $filepath;
                cd $filepath
        fi
done

#### The below commands print the date that your
#### job finished running to the log, and then
#### calcualtes the total amount of time it took
#### for the job to complete
date
end=`date +%s`
runtime=$((end-start))
echo "runtime=$runtime secs"
echo "$JOB_NAME FINISHED   $runtime secs" >> ../job_status.txt
