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
`wget http://www.uniprot.org/uniprot/$file.fasta -O seq.txt`;
#$cwd=`pwd`;
#Psiblast against nr database
if(!-s "$file.chk" || !-s "pssm.txt" || !-s "blast.out")
{
    print "doing psiblast\n";
    `$blastdir/bin/blastpgp -a 50 -b 0 -v 5000 -j 3 -h 0.001 -d $db -i seq.txt -C $file.chk -Q pssm.txt > blast.out"`;
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

	`$adddir/DOMAINS_QUARK_SEQUENCE.pl $file`;

	print "Boundaries are processed and are ready for QUARK SUBMISSION\n"; 

#Quark step 
        print "Submitting to QUARK\n";

	`$adddir/Automate_Quark.sh > QUARK.output`;
	print "check QUARK.output file to find the status of QUARK";
	
if(!-s "pre.sol")
{
	print "predict solve\n";
	`$bindir/getannfeature 6 $file.chk $file.ss2 annfeat6.dat`;
	`$bindir/simple_onetestsas 6 100 $bindir/sastrainres6-100.net annfeat6.dat pre.sol`;
	`rm annfeat6.dat`;
}
#AIDA step 
	`cp $file.ss2 protein.ss2`; 
	$nd=`find . -maxdepth 1 -name "pmodel*.pdb" | wc -l`;
	chomp($nd);
	print "number of domains to assemble are: $nd\n"; 
	print "Assembling the structure using AIDA..\n";
	$random = int(rand(10000)); 
	$time=100000; 
	print "$time\n"; 
	`$bindir/aida $random ../$file $bindir $nd $time > aida.output`;

		print("Assembled output structure from AIDA is",$random,"decoys.pdb \n");

        $decoys="decoys.pdb";
        $input_aida="$random$decoys";
        open(output, ">$file.AHEMODEL_INPUT") || die("could not open the output file");
        open(input,"$input_aida") || die("could not find decoys file");
        @aida_out = <input>;
        chomp(@aida_out);
        foreach $line (@aida_out)
        {
                @occupancy = split(/ +/, $line);
                if($line =~ "ATOM")
                {
                        printf output ("%0.54s  $occupancy[8].00  0.00\n", $line);
                }
        }
        `cp /home/LAB/ECOLI_2017/PROTEIN_STRUCTURES/input_file_for_ahemodel .`;
         `sed -i '/^>/d' seq.txt`;
        `$adddir/make_pseudo_seqres.exe seq.txt A`;
        `$adddir/give_empty_chain_column_name.exe $file.AHEMODEL_INPUT A`;
        `cat pseudo_SEQRES.pdb blank_no_more.pdb > TEMPLATE.pdb`;
        `sed -i -- 's/PXXXXX/$file/g' input_file_for_ahemodel`;
#Building side chains using AHEMODEL
        `rm nohup.out; nohup /home/aelcock/CURRENT_CODES/ahemodel_loop6_timeout_deletion_9999res_forbid_unclosed_loops_correct_Cter_membrane_aware_hand_align_optional_seqres_mandatory_needle_tail_rebuild_optional_input_file_HETATM.exe < input_file_for_ahemodel &`;
####END########		
exit();
