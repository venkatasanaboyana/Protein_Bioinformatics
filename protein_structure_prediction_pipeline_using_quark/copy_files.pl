#!/usr/bin/perl

$file = $ARGV[0];
$dir = $ARGV[1];
$user = $ARGV[2];

	`scp $user@mgz.biochem.uiowa.edu:~/$dir/$file/$file.domain_*.fasta .`;
	`scp $user@mgz.biochem.uiowa.edu:~/$dir/$file/$file.domain_list.txt .`;
	`scp $user@mgz.biochem.uiowa.edu:/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/Automate_Quark_Desktop.sh .`;
	`scp $user@mgz.biochem.uiowa.edu:/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/QUARK_SUBMISSION.pl .`;
	`scp $user@mgz.biochem.uiowa.edu:/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/AIDA/renumber .`;


