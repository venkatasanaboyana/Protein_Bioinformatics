#!/usr/bin/perl
$blastdir="/home/LAB/BIN/I-TASSER/I-TASSER4.1/blast";
$psipreddir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/PSIPRED/psipred";
$domdatadir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/DOMPRED";
$javadir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/JAVA/jdk-9.0.1/bin"; 
$bindir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/AIDA";
$adddir="/home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY"; 

################################################################

	$file = $ARGV[0] || die "please make sure the working directory's name is same as uniprotID and provide uniprotID as first argument\nnode= 01, 02, 03, 04, 05, 06 as second argument\nQuark username, eg:venkata-sanaboyana from QUARK E-mail venkata-sanaboyana\@uiowa.edu as third argument\nand Quark paswword as fourth argument\nmachine's username as fifth argument\n\nexample: Assembly_whole_submit_nodes.pl P33355 02 venkata-sanaboyana 645361 vsanaboyana\nEXITING NOW\n";

	$QUARK_DECISION = $ARGV[1]; 

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
	
if(!-s "pre.sol")
{
	print "predict solve\n";
	`$bindir/getannfeature 6 $file.chk $file.ss2 annfeat6.dat`;
	`$bindir/simple_onetestsas 6 100 $bindir/sastrainres6-100.net annfeat6.dat pre.sol`;
	`rm annfeat6.dat`;
}
open (domain_input, "$file.domain_list_modified.txt") || die("could not find domain_list file");
@domain_list = <domain_input>;
chomp(@domain_list);
$line_count = 1;

foreach $line (@domain_list)
{
        $filename_pdb=`echo "$line" | rev | cut -c 7- | rev`;
        chomp($filename_pdb);
        `$bindir/renumber seq.txt $filename_pdb.pdb pmodel$line_count.pdb`;
        $line_count = $line_count + 1;
}

	`cp seq.txt $file.txt`; 
#AIDA step 
	`cp $file.ss2 protein.ss2`; 
	$nd=`find . -maxdepth 1 -name "pmodel*.pdb" | wc -l`;
	chomp($nd);
	
	if($QUARK_DECISION =~ "Y")
	{
		$first_line = `head -1 pmodel1.pdb`;
		$last_line = `tail -1 pmodel$nd.pdb`; 
		@temp = split(/ +/, $first_line);
		$first = $temp[4];
		@temp = split(/ +/, $last_line);
		$last = $temp[4];
		&sequence($first, $last);
		`cp seq_aida.txt seq.txt`; 
					
	}
	$random = int(rand(10000)); 
	$time=100000;
	$decoys="decoys.pdb";	
	if($nd > 1)
	{
		print "number of domains to assemble are: $nd\n"; 
		print "Assembling the structure using AIDA..\n";

		`$bindir/aida $random ../$file $bindir $nd $time > aida.output`;

		print("Assembled output structure from AIDA is",$random,"decoys.pdb \n");
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

	}
	else{
		print("skipping AIDA step because number of domains to assemble are 1\n");
	
                `cp /home/LAB/ECOLI_2017/PROTEIN_STRUCTURES/input_file_for_ahemodel .`;
		`sed -i s/yes/no/g input_file_for_ahemodel`; 
       		`$bindir/renumber seq.txt pmodel1.pdb model1_renumbered.pdb`;
		`$adddir/give_empty_chain_column_name.exe model1_renumbered.pdb A`;
		`$adddir/make_pseudo_seqres.exe seq.txt A`; 
		`cat pseudo_SEQRES.pdb blank_no_more.pdb > temp_AHE.pdb`; 
        	`/home/aelcock/CURRENT_CODES/remove_alternative_conformations_in_pdb.exe temp_AHE.pdb temp.pdb ; mv temp.pdb FINAL.OPM.pdb`;
		`/home/aelcock/CURRENT_CODES/match_SEQRES_entries_to_PISA_pdb_file.exe temp_AHE.pdb FINAL.OPM.pdb TEMPLATE.pdb`; 
        	`sed -i -- 's/PXXXXX/$file/g' input_file_for_ahemodel`;
#Building side chains using AHEMODEL
	 	`rm nohup.out; nohup /home/aelcock/CURRENT_CODES/ahemodel_loop6_timeout_deletion_9999res_forbid_unclosed_loops_correct_Cter_membrane_aware_hand_align_optional_seqres_mandatory_needle_tail_rebuild_optional_input_file_HETATM.exe < input_file_for_ahemodel &`;
####END########
	  }
sub sequence {

        ($start, $end) = @_;
        open(output, ">seq_aida.txt");
        print output (">aida\[$start, $end\]\n");
        open(input, "$file.txt") || die("could not find the sequence file\n");
        @seq_file = <input>;
        chomp(@seq_file);
        foreach $line (@seq_file)
        {
                if($line !~ ">")
                {
                        chomp($line);
                        @split_char = split(//, $line);
                        for($c1=0; $c1<@split_char; $c1++)
                        {
                                push(@seq, $split_char[$c1]);
                        }

                }
        }
        $n=0;
        for($c = 0; $c < @seq; $c++)
        {
                if($c >= $start && $c <= $end)
                {
                        print output ($seq[$c]);
                        $n++;
                }
                if($n == 60)
                {
                        print output ("\n");
                        $n=0;
                }
        }

}

		
###################end
exit();
