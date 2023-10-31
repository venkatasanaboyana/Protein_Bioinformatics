#!/bin/bash


	ssh $3@mgz.biochem.uiowa.edu "mkdir -p /home/$3/$6/$1; cp  /home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/Assembly_whole_desktop_part*  /home/$3/$6/$1/."

	#cat seq.txt | ssh $3@mgz.biochem.uiowa.edu "cat >> /home/$3/$6/$1/seq.txt";
	scp seq.txt $3@mgz.biochem.uiowa.edu:/home/$3/$6/$1/.

	ssh $3@mgz.biochem.uiowa.edu "cd /home/$3/$6/$1/; ./Assembly_whole_desktop_part1.pl $1 $2 $3"
	
while true
do

        if ssh $3@mgz.biochem.uiowa.edu stat /home/$3/$6/$1/$1.domain_list.txt \> /dev/null 2\>\&1
            then
                    echo "Files are ready for Quark, and are being copied."
                    scp $3@mgz.biochem.uiowa.edu:/home/$3/$6/$1/$1.domain_*.fasta .
                    scp $3@mgz.biochem.uiowa.edu:/home/$3/$6/$1/$1.domain_list.txt .
                    scp $3@mgz.biochem.uiowa.edu:/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/Automate_Quark_Desktop.sh .
                    scp $3@mgz.biochem.uiowa.edu:/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/QUARK_SUBMISSION.pl .
                    break;

            else
                    echo "BLAST, PSIPRED and DOMPRED programs are still running"
                    echo "."
                    sleep 5m;

        fi
done
	
	
	if [ -e $1.domain_1.fasta ] || [ -e $1.domain_list.txt ] 
	then
		echo Submitting files for Quark! Check the status in Quark.output file	
		./Automate_Quark_Desktop.sh $4 $5;
        fi


	if [ ! -e  QUARK_SUBMISSION_CONTENT ]
	then
		scp $1.domain_*.pdb $3@mgz.biochem.uiowa.edu:/home/$3/$6/$1/.
		ssh $3@mgz.biochem.uiowa.edu "cd /home/$3/$6/$1/; ./Assembly_whole_desktop_part2.pl $1"
	fi 
	
        echo we are done here. log on mgz, go to the directory you created to run this job, and see the output files.  

