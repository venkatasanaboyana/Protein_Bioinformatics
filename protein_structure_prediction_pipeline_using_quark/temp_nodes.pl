#!/usr/bin/perl
$db="/home/LAB/BIN/I-TASSER/I-TASSER4.1/blast/ncbi-blast-2.2.29+/nr/nrfilt_01.2018/nrfilt";
$blastdir="/home/LAB/BIN/I-TASSER/I-TASSER4.1/blast";
$psipreddir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/PSIPRED/psipred";
$domdatadir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/DOMPRED";
$javadir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/JAVA/jdk-9.0.1/bin"; 
$bindir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/AIDA";
$adddir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY"; 
$file = $ARGV[0];
print "downloading the fasta\n";
#`wget http://www.uniprot.org/uniprot/$file.fasta -O seq.txt`;
$cwd=`pwd`;
#Psiblast against nr database
if(!-s "$file.chk" || !-s "pssm.txt" || !-s "blast.out")
{
    open(submit, ">submit.sh");
    print submit ("#!/bin/sh\n");
    print submit ("$blastdir/bin/blastpgp -a 50 -b 0 -v 5000 -j 3 -h 0.001 -d $db -i $cwd/seq.txt -C $cwd/$file.chk -Q $cwd/pssm.txt > $cwd/blast.out");
}
		
###################end
exit();
