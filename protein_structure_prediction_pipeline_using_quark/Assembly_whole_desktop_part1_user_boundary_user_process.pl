#!/usr/bin/perl
$blastdir="/home/LAB/BIN/I-TASSER/I-TASSER4.1/blast";
$psipreddir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/PSIPRED/psipred";
$domdatadir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/DOMPRED";
$javadir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/JAVA/jdk-9.0.1/bin"; 
$bindir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/AIDA";
$adddir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY"; 
$n01_db="/home/LAB/BIN/I-TASSER/I-TASSER4.1/blast/ncbi-blast-2.2.29+/nr/nrfilt_01.2018/nrfilt";
$n02_db="/scratch3/vsanaboyana/NR-DATABASE/nrfilt_01.2018/nrfilt";
$n03_db="/scratch2/vsanaboyana/NR-DATABASE/nrfilt_01.2018/nrfilt";
$n04_db="need to mount the 04";
$n05_db="/scratch2/vsanaboyana/NR-DATABASE/nrfilt_01.2018/nrfilt";
$n06_db="/scratch2/vsanaboyana/NR-DATABASE/nrfilt_01.2018/nrfilt";
$DOMPRED_result="/home/tcollingsworth/PSI-RESULTS_FOR_VENKAT";
################################################################

	$file = $ARGV[0] || die "please make sure the working directory's name is same as uniprotID and provide uniprotID as first argument\nnode= 01, 02, 03, 04, 05, 06 as second argument\nQuark username, eg:venkata-sanaboyana from QUARK E-mail venkata-sanaboyana\@uiowa.edu as third argument\nand Quark paswword as fourth argument\nmachine's username as fifth argument\n\nexample: Assembly_whole_submit_nodes.pl P33355 02 venkata-sanaboyana 645361 vsanaboyana\nEXITING NOW\n";
	$node = $ARGV[1] || die "Please make sure the working directory's name is same as uniprotID and provide the node you want to use as second argument; node= 01, 02, 03, 04, 05, 06\nQuark username; eg:venkata-sanaboyana from QUARK E-mail venkata-sanaboyana\@uiowa.edu as third argument\nQuark paswword as fouth argument\nmachine's username as fifth argument\n\nexample: Assembly_whole_submit_nodes.pl P33355 02 venkata-sanaboyana 645361 vsanaboyana\nEXITING NOW\n";
	$user = $ARGV[2] || die "provide your current machine's username as fifth argument\n\nexample: Assembly_whole_submit_nodes.pl P33355 02 venkata-sanaboyana 645361 vsanaboyana\nEXITING NOW\n"; 

	$argc = $#ARGV + 1;

if ($argc < 3)
	{
		print "usage: Assembly_whole_submit_nodes.pl uniprot node quark_username quark_password\n";
		print "where uniprot= PXXXXX; node= 01, 02, 03, 04, 05, 06\n\n";
		print "example: Assembly_whole_submit_nodes.pl P33355 02 venkata-sanaboyana 645363\n\n";
		print "exiting because of insufficient arguments. :(\n";

		exit 1;
	}

#	print "downloading the fasta\n";
#	`wget http://www.uniprot.org/uniprot/$file.fasta -O seq.txt`;
if (!-e "seq.txt")
{
	print "please copy the uniprot sequence from the database using the link below and save it as seq.txt in fasta format \n";
	print "Sequence can be found in the sequence column, adjacent to uniprotID in the MASTER spread sheet\n";
	print "https://docs.google.com/spreadsheets/d/1hclw5Qewwvx5OJqNBIrvQEkN5FIDZb1FAMMrtgr83V0/edit?usp=sharing\n\n";

	print "EXITING NOW\n";  
	
	exit 1; 
}
	$cwd=`pwd`;
	$double='"'; 
chomp($cwd);
#Psiblast against nr database
if(!-s "$$DOMPRED_result/$file/$file.boundary")
{
	print("SKIPPING DOMPRED PROCEDURE AND COPYING FILES FROM TIM's FOLDER\n"); 
	`scp $DOMPRED_result/$file/* .`; 

}
else{

if(!-s "$file.chk" || !-s "pssm.txt" || !-s "blast.out")
{
	open(submit, ">submit.sh");
        print submit ("#!/bin/bash\n");
	if($node == "01")
	{
		print submit ("ssh -t -t $user\@n$node $double$blastdir/bin/blastpgp -a 64 -b 0 -v 5000 -j 3 -h 0.001 -d $n01_db -i $cwd/seq.txt -C $cwd/$file.chk -Q $cwd/pssm.txt > $cwd/blast.out$double");
	}
	if($node == "02")
        {
                print submit ("ssh -t -t $user\@n$node $double$blastdir/bin/blastpgp -a 64 -b 0 -v 5000 -j 3 -h 0.001 -d $n02_db -i $cwd/seq.txt -C $cwd/$file.chk -Q $cwd/pssm.txt > $cwd/blast.out$double");
        }
	if($node == "03")
        {
                print submit ("ssh -t -t $user\@n$node $double$blastdir/bin/blastpgp -a 64 -b 0 -v 5000 -j 3 -h 0.001 -d $n03_db -i $cwd/seq.txt -C $cwd/$file.chk -Q $cwd/pssm.txt > $cwd/blast.out$double");
        }
	if($node == "04")
        {
		print "please mount NR-database in the node 04. For now try n01, n02, n03, n05 and n06\nEXITING NOW\n"; exit 1; 
                print submit ("ssh -t -t vsanaboyana\@n$node $double$blastdir/bin/blastpgp -a 50 -b 0 -v 5000 -j 3 -h 0.001 -d $n04_db -i $cwd/seq.txt -C $cwd/$file.chk -Q $cwd/pssm.txt > $cwd/blast.out$double");
        }
	if($node == "05")
        {
                print submit ("ssh -t -t $user\@n$node $double$blastdir/bin/blastpgp -a 64 -b 0 -v 5000 -j 3 -h 0.001 -d $n05_db -i $cwd/seq.txt -C $cwd/$file.chk -Q $cwd/pssm.txt > $cwd/blast.out$double");
        }
	if($node == "06")
        {
                print submit ("ssh -t -t $user\@n$node $double$blastdir/bin/blastpgp -a 64 -b 0 -v 5000 -j 3 -h 0.001 -d $n06_db -i $cwd/seq.txt -C $cwd/$file.chk -Q $cwd/pssm.txt > $cwd/blast.out$double");
        }
	`bash submit.sh`;
}
		
if(!-s "$file.mtx")
{      
    `cp seq.txt $file.fasta`;
    `echo $file.chk > $file.pn`;
    `echo $file.fasta > $file.sn`;
    `$blastdir/bin/makemat -P $file`;
    `cp $file.mtx mtx`;
    `rm $file.fasta $file.pn $file.sn $file.mn $file.aux`;
}
#psipred step 
if(!-s "$file.ss2" || !-s "$file.horiz")
{
	print "doing psipred\n";
	`$psipreddir/bin/psipred $file.mtx $psipreddir/data/weights.dat $psipreddir/data/weights.dat2 $psipreddir/data/weights.dat3 > $file.ss`;
	`$psipreddir/bin/psipass2 $psipreddir/data/weights_p2.dat 1 1.0 1.0 $file.ss2 $file.ss > $file.horiz`;
	`$bindir/ss22dat $file.ss2 seq.dat`;
	`rm $file.ss`;
}

	print "blast against nr data base is finished\n";
	print "files generated are $file.chk, $file.ss2, $file.ss and $file.horiz\n";
	print "\n";

#psiblast against Pfam database
if(!-s "$file.blastdom")
{
	print "running blast against PfamA\n";
	`$blastdir/bin/blastpgp -a 50 -j 5 -m 0 -b 1000 -d $domdatadir/data/uniref90_PfamA -i seq.txt > $file.blastdom`;
}
#dompred step	

	`cp $domdatadir/dompred-master/src/DomSSEA.class .`;
	`cp -r $domdatadir/dompred-master/src/org .`;
	`cp $domdatadir/dompred-master/parseDS_VR.pl .`;

	`$javadir/java DomSSEA $file $domdatadir/data/All_cut3`;

	print "Dompred is finished\n";

#parsing step 
	print "Parsing the Dompred output\n";
	`./parseDS_VR.pl $file.domssea seqyes PfamA 0.01 5 domsseayes ppyes secproyes ../$file $domdatadir/data/uniref90_PfamA ../$file $domdatadir/data /usr/local/bin/gnuplot`; 
	if(-s "$file.boundary" && -s "$file.graph" && -s "$file.pred")
	{ 
		print "Parsing is finished and generated $file.boundary, $file.graph and $file.pred output files\n";
	}	
	else
	{	print "something is wrong with the parsing step\n";}

#processing step	
	print "processing the domain boundaries identfied and parsed by DOMPRED\n"; 
}

	do 'DOMAINS_QUARK_SEQUENCE_USER_DEFINE_AND_PROCESS_BOUNDARIES.pl';

	print "Boundaries are processed and are ready for QUARK SUBMISSION\n"; 

###################end
exit();
