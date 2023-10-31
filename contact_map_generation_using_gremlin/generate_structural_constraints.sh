#!/bin/bash
#This script is to automate the process of obtaining metagenomic restraints.
#v3.0 includes copying fasta to the local scratch and do the hmmsearch process.  

dir=$(pwd)
matured=PSIPRED_DOMPRED_DISOPRED_MATURE_FASTA

uniprot=$1;
queue=$2; 
cpu=$3; 
num_jobs=$4; 

if [ "$#" -lt 4 ]
        then
           echo "";
           echo "################  YOU MADE AN ERROR FRIEND   ##################################";
           echo "INSUFFICIENT NUMBER OF ARGUMENTS; PLEASE LOOK AT THE FOLLOWING EXAMPLE FOR USAGE";
           echo "################################################################################"
	   echo "";
           echo "USAGE EXAMPLE: ./generate_meta_constraints_v2.0.sh PXXXXX queue_system num_threads num_jobs";
           echo "PXXXXX: UNIPROT_ID";
           echo "que_system: The elcock queue is called FERBIN; Some other queues are UI, UI-HM, CCOM, all.q";
           echo "num_threads: Number of threads per each job (e.g. 2 threads for each of the 293 jobs)";
	   echo "num_jobs: Number of meta genomes per each job";
           echo "";
           echo "JOB SUBMISSION IS UNSUCCESSFUL; TERMINATING NOW!! :(";
	   echo "################################################################################"
           exit 1;

        fi


mkdir -p ${uniprot}_${queue}_${cpu}_$num_jobs/hhblits
mkdir ${uniprot}_${queue}_${cpu}_$num_jobs/hmmsearch
mkdir ${uniprot}_${queue}_${cpu}_$num_jobs/Analysis

##########hhblits##############
cp $dir/hhblits.job ${uniprot}_${queue}_${cpu}_$num_jobs/hhblits/.
cd ${uniprot}_${queue}_${cpu}_$num_jobs/hhblits/
if [ ! -f "query.fasta" ] 
then 
	cp $matured/$uniprot/${uniprot}.fasta query.fasta      #Using stepDB fasta
	#wget https://www.uniprot.org/uniprot/$uniprot.fasta -O query.fasta
fi

##########hhblits##############

if [ ! -s "query.hmm" ]
then
	qsub hhblits.job                                       #If no query.hmm, hhblits.job is submitted
fi


time_check=5; 
###########checking for the output of hhblits###############

while true
do
	if [[ -s "query.hmm" && -s "query_id90cov75.cut.fas" ]]
	then
        	cp query.hmm ../hmmsearch/.
		break; 	
	else
		echo "hhblits is running; will check after $time_check m"
                time_check=$(( time_check + 5 ));
                sleep 2m;
	fi
done
		echo "starting hmmsearch" 
		cd ../hmmsearch/
        	cp $dir/master_script.sh .
		cp $dir/template_script_localscratch.sh template_script.sh

		##### MODIFY template_script.sh #####
		sed -i "s/.*#$ -pe smp/#$ -pe smp $cpu/" template_script.sh
		sed -i "s/.*#$ -q/#$ -q $queue/" template_script.sh
		sed -i "s/.*CPU=/CPU=$cpu/" template_script.sh
		sed -i "s/.*num_jobs=/num_jobs=$num_jobs/" template_script.sh
		sed -i "s/.*uniprot=/uniprot=$uniprot/" template_script.sh
		#####################################
 
        	cp $dir/faa_path.txt .
        	mkdir Uniref100
        	cp $dir/hmmsearch_uniref.job Uniref100/
        	cp $dir/submit_all.sh .
        	cp $dir/list_jobs.txt .
		if [ ! -s "job_status.txt" ]  
		then
			bash master_script.sh $num_jobs
	 		bash submit_all.sh
		fi

######## CHECKING IF HMMSEAECH IS FINISHED #################
echo "checking for the file - job_status.txt"; 
while true
do
	if [ -s "job_status.txt" ]
	then
		echo "Yes, I found it; Now will be checking if all the jobs are completed"
		break; 
	else
		echo "checking for the file - job_status.txt"
		sleep 10m; 
	fi
done
num_jobs_finished=`cat job_status.txt | wc -l`
time_check2=20; 
num_meta_jobs=$(((14613+($num_jobs - 1))/$num_jobs)); #ROUNDING UP and 14613 is the number of meta sequences
while true
do
	if [[ $num_jobs_finished == $num_meta_jobs && -s "Uniref100/all_msa.sto"  ]]
	then	
		echo "All the hmmsearch jobs are completed"
		echo "Starting the analysis"
		break; 
	else 
		echo "hmmsearch still running; will check after $time_check2 m"
                time_check2=$((time_check2+20))
		num_jobs_finished=`cat job_status.txt | wc -l`
                sleep 20m

	fi 
done
		echo "Analysis is being performed"
		cd ../Analysis/
		mkdir all_metagenome_sto_files
		for i in $(seq 1 $num_meta_jobs)
		do
			mkdir all_metagenome_sto_files/meta-$i
     			cd ../hmmsearch/meta-$i
     			########## COPYING NON EMPTY STO FILES #############
			find . -maxdepth 1 -name '*.sto' ! -empty -type f -exec cp {} ../../Analysis/all_metagenome_sto_files/meta-$i/. \;
			cd ../../Analysis/
		done

#################### ANALYSIS ##############################

bash $dir/analyse_chunks10.sh

##################### GREMLIN ##############################

cp $dir/gremlin.job .
qsub gremlin.job


###################### RENUMBER THE RESTRAINTS #############

while true
do
	if [[ -s "Gremlin_raw_contacts.txt"  && -s "meta_uniref_cov75id90.cut" ]]
	then
		cp $dir/sigmoidal_values.csv . 
		$dir/renumber_gremlin_contacts.pl meta_uniref_cov75id90.cut Gremlin_raw_contacts.txt
		break
	else
		sleep 2m; 
	fi
done
