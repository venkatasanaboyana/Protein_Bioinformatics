#!/usr/bin/perl

$EVALUE = 1.0e-5;
$PERCENT_COVERAGE = 0;  
$IP = "mgz.biochem.uiowa.edu"; 

if($PERCENT_COVERAGE == 0)
{
	print "\nCRITERIA BEING USED FOR SEQATOMS IS ONLY EVALUE\n\n";
}
else
{
	print "\nCRITERIA BEING USED FOR SEQATOMS IS EVALUE AND PERCENT COVERAGE\n\n";
}


#$file = $ARGV[0] || die "please provide the fasta file\n"; 
$uniprot = $ARGV[0] || die "Please provide the uniprot\n";
$user = $ARGV[1] || die "please provide the username for the machine\n"; 
$directory = $ARGV[2] || die "please provide the directory you named\n";
$username = $ARGV[3] || die "please provide quark username\n"; 
$password = $ARGV[4] || die "please provide quark password\n"; 

open(input, "$uniprot.domain_list.txt") || die("could not locate domain_list file\n"); 
@domain_input = <input>; 
chomp(@domain_input); 
$dom_count = 1; $dom_pdb_count = 100; #arrays in the following loop are named based on these identities. 

foreach $file (@domain_input)
{
	@align_len = ();
	@bit_score = (); 
	@evalue = (); 
	@pdb = (); 
	@chain = (); 
	@PDB_CHAIN = ();
	push(@domain_name, $file); 
	push(@pdb_array_name, $dom_pdb_count); 
        do{							#SUBMITS TO SEQATOMS UNTIL SERVER RETURNS THE OUTPUT
	#	print "submitting the $file to seq atoms\n"; 	
		`perl submit_seqatoms.pl $file > seqatoms_output`;
	open (input, "seqatoms_output") || die ("could not locate seqatoms_output file\n");
	@seq_atoms_xml = <input>; 
	}while(! @seq_atoms_xml); 
	#print "processing the seq_atom output file\n";	
	chomp(@seq_atoms_xml);
	$line_count=0; $i=0;
	foreach $line (@seq_atoms_xml)
	{
		if($line =~ "<BlastOutput_query-len>")
		{
			@Query = split(/[>,<,|,_,\s\/]+/, $seq_atoms_xml[$i]);
			$Query_length = $Query[3];
		}

		if($line =~ "<Hit_num>")
		{
			for($j=$i; $j<$i+25; $j++)
			{
				@split_line = split(/[>,<,|,_,\s\/]+/, $seq_atoms_xml[$j]);
				$k = $j - $i; 
				if($k == 20)
				{  
					push(@align_len, $split_line[3]);
				}
				if($k == 8)
				{
					push(@bit_score, $split_line[3]);
				}
				if($k == 10)
				{
					push(@evalue, $split_line[3]);
				}
				if($k == 2)
				{
					push(@pdb, $split_line[4]); 
					push(@PDB_CHAIN, '1'); 
					$PDB_CHAIN[-1] = "$split_line[4]_$split_line[5]";   #PDB ID and chain identifier in the same array. 
					push(@chain, $split_line[5]); 
				}
			}	
		}	
		$i++;

	}
	&sort(@evalue);
	#sorting PDB ID's based on evalue
	for($i=0; $i<@sorted_list_index; $i++)
	{
		push(@$dom_pdb_count, $PDB_CHAIN[$sorted_list_index[$i]]);    #sorted PDB_chain's based on evalues are stored in the arrays named 100, 101, ...
	}
	##
	for($i=0; $i<@sorted_list; $i++)
	{
		$seq_coverage_percent = ($align_len[$sorted_list_index[$i]]/$Query_length)*100; 
		&alignment_color($bit_score[$sorted_list_index[$i]]);
		if($sorted_list[$i] < $EVALUE)
		{
			if($seq_coverage_percent > $PERCENT_COVERAGE)
			{
				
				@$dom_count = @sorted_list;                     #sorted evalues for each domain are stored in the arrays named 1,2,3...
			} 

		}
	}

	if(@$dom_count)
	{
		push(@check, "1");
		
	}
	else{ 
		push(@check, "0"); 
	}
 
	$dom_count++; 
	$dom_pdb_count++; 
}

#$filename_pdb=`echo "$file" | rev | cut -c 7- | rev`;
#chomp($filename_pdb);
$count = 0;

$same =0; 
	print("\n\n*****************************\n");
	print("###########USER INTERVENTION REQUIRED##########\n");
	print("*********************************\n"); 

for($i=0; $i<@check; $i++)
{
	print("\nEnter details about ", $domain_name[$i], " (Press N for QUARK job)\n");
	print("Do you want to choose the template by yourself or let the program decide? \n"); 
	print("\nEnter 'Y' for the User or 'N' for the program (Y/N): "); 
	$decision = <STDIN>; 
	push(@decisions, $decision); 
	print("\n"); 
	if($decision =~ 'Y')
	{
		print("Please enter the template PDB for $domain_name[$i] you think is appropriate: "); 
		$PDB = <STDIN>;
		chomp($PDB);  
		print("corresponding chain: "); 
		$PDB_chain = <STDIN>;
		chomp($PDB_chain); 
		push(@PDB_user, $PDB); 
		push(@PDB_chain_user, $PDB_chain);  
	}
	else{
		push(@PDB_user, "N");
                push(@PDB_chain_user, "N");
	}
}

print(@domain_name,"\n");
for($i=0; $i<@check; $i++)
{	
	if($decisions[$i] =~ 'Y')
	{
		&AHEMODEL($PDB_user[$i], $PDB_chain_user[$i], $domain_name[$i]);		 
	}
	if($decisions[$i] =~ 'N')
	{
	if($check[$i] == 1) 
	{
		if(scalar @check == 1)
		{
			@temp = @{$pdb_array_name[$i]}; 
			$PDB_chain = $temp[0]; 
			@split_PDB_chain = split(/_/, $PDB_chain); 
			&AHEMODEL($split_PDB_chain[0], $split_PDB_chain[1], $domain_name[$i]); 
			$same = 0; 
		}
		if($check[$i+1] == 0)
		{
			@temp = @{$pdb_array_name[$i]};
                        $PDB_chain = $temp[0];
			if($same == 0)
			{
                        	@split_PDB_chain = split(/_/, $PDB_chain);
                        	&AHEMODEL($split_PDB_chain[0], $split_PDB_chain[1], $domain_name[$i]);
			}
			$same =0; 
		
		}
		if($check[$i+1] == 1)
		{
			#do
			{
             			&compare(\@{$pdb_array_name[$i]}, \@{$pdb_array_name[$i+1]});  #accessing array from an array. 
				if($match =~ "TRUE")
				{
					$same++;
					if($same == 1)
					{
						push(@PDBS, $i);
						push(@PDBS, $i+1); 	
					}  
					if($same > 1)
					{
						$PDBS[-1] = $i+1;
					}
				 
				}
				if($match =~ "FALSE")
				{
					if($same == 0)
					{
						@split_PDB_chain = split(/_/, $PDB1); 
					}
					else{	@split_PDB_chain = split(/_/, $PDB2);
						$i = $i+1; 
					}
					&AHEMODEL($split_PDB_chain[0], $split_PDB_chain[1], $domain_name[$i]); 
					$same =0; 
				}
			} 
		 	
		}
	}
	else{
		&QUARK($domain_name[$i]);
	}
        } 
	if($same == 0)
	{
		if(@PDBS){
			&concat($domain_name[$PDBS[0]], $domain_name[$PDBS[1]]);
			&sequence($find_start[0], $find_end[1], $PDBS[0]);
			$insert = $domain_name[$PDBS[0]]; 
			splice(@domain_name, $PDBS[0], $PDBS[1] - $PDBS[0] + 1);
			splice(@domain_name, $PDBS[0], 0, $insert); 
			print("Generating a common pdb for the domains $PDBS[0] to $PDBS[1]:  $PDB1\n");
			@split_PDB_chain = split(/_/, $PDB1);
			`scp $insert $user\@$IP:/home/$user/$directory/$uniprot/.`; 
			&AHEMODEL($split_PDB_chain[0], $split_PDB_chain[1], $insert);  
		}
		@PDBS = (); 
	}
	
}

open(domain_list, ">$uniprot.domain_list_modified.txt");
for($i=0; $i<@domain_name; $i++)
{
	print domain_list ($domain_name[$i], "\n");
}

print(@domain_name,"\n"); 
sub AHEMODEL {
	($pdb_wo_chain, $chain, $fasta) = @_; 
	print "DOMAIN WILL BE SUBMITTED FOR AHEMODEL BUILDING\n";
	print("values for AHE MODEL are $pdb_wo_chain\t$chain\t$fasta\n"); 
	`ssh $user\@$IP "cd /home/$user/$directory/$uniprot;cp /home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/SUBMIT_AHEMODEL_NMR_RIGID.sh .;bash SUBMIT_AHEMODEL_NMR_RIGID.sh $pdb_wo_chain $chain $fasta"`; 	
}

sub QUARK {
	($fasta) = @_; 
	print "\n\nNO HOMOLOGOUS TEMPLATE AVAILABLE, THEREFORE CANNOT BE SUBMITTED FOR AHEMODEL BUILDING\n";
	print "DOMAIN WILL BE SUBMITTED FOR QUARK\n";
	`./SUBMIT_QUARK.sh $fasta $username $password`; 
}

sub sort {

	(@abc) = @_;
	$l = 0;

	@temp_abc = map { {value=>$_, index=>$l++} } @abc;
	@sorted_temp_abc = sort { $a->{value} <=> $b->{value} } @temp_abc; 
	@sorted_list = map { $_->{value} } @sorted_temp_abc;
	@sorted_list_index = map { $_->{index} } @sorted_temp_abc;
}

sub compare {
	($array1, $array2) = @_;
	for($a=0; $a<@$array1; $a++)
	{
		for($b=0; $b<@$array2; $b++)
		{
			if($$array2[$b] =~ $$array1[$a])
			{
				$PDB1 = $$array1[$a];
				$PDB2 = $$array2[$b]; 
				$match = "TRUE";
				$b = scalar @$array2; $a = scalar @$array1;   
			}
			else{
				$PDB1 = $$array1[0];
				$PDB2 = $$array2[0]; 
				$match = "FALSE"; 
			}
		}
	}
}

sub concat { 
	($file1, $file2) = @_; 
	$f1 = `grep ">" $file1`; chomp($f1);  
	@find_start = $f1 =~ /\[(.*?),(.*?)\]/g; 
	chomp(@find_start); 		
	$f2 = `grep ">" $file2`; chomp($f2); 
	@find_end = $f2 =~ /\[(.*?),(.*?)\]/g;
	chomp(@find_end);
	return $find_start[0]; 	
	return $find_end[1]; 
}

sub sequence {
	
	($start, $end, $num) = @_; 
	open(output, ">$domain_name[$num]"); 
	print output (">$uniprot.domain_x\[$start, $end\]\n");
	open(input, "seq.txt") || die("could not find the sequence file\n"); 
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

sub alignment_color {

	($value) = @_; 
         if($value >= 200)
	 {
		$color = "RED";
	 }
	 if($value > 80 && $value < 200)
	 {
		$color = "PINK";
	 }
	 if($value > 50 && $value < 80)
         {
                $color = "GREEN";
         }
         if($value > 40 && $value < 50)
         {
                $color = "BLUE";
         }
	 if($value < 40)
	 {	$color = "BLACK"; }
}
