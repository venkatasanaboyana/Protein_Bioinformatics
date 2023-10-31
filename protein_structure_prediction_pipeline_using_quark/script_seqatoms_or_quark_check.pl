#!/usr/bin/perl

$EVALUE = 1.0e-5;
$PERCENT_COVERAGE = 0;  
$IP = "mgz.biochem.uiowa.edu"; 

$uniprot = $ARGV[0] || die "Please provide the uniprot\n";

open(input, "$uniprot.domain_list.txt") || die("could not locate domain_list file\n");
@domain_input = <input>;
chomp(@domain_input);
$line = 1; 
foreach $file (@domain_input)
{

	@align_len = ();
        @bit_score = ();
        @evalue = ();
        @pdb = ();
        @chain = ();
	$ex=1;
        do{                                                     #SUBMITS TO SEQATOMS UNTIL SERVER RETURNS THE OUTPUT
                `perl submit_seqatoms.pl $file > seqatoms_output`;
        open (input, "seqatoms_output") || die ("could not locate seqatoms_output file\n");
        @seq_atoms_xml = <input>;
        $ex++;
        if($ex>5)
	{print("\n\n####ERROR####\nPLEASE CHECK if $uniprot.domain_list AND CORRESPONDING FASTA FILES ARE CONSISTENT\n");
        exit 1; }
        }while(! @seq_atoms_xml);

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
			}
			}
		}
		$i++;

	}

	&sort(@evalue);
	@check = (); 

	for($i=0; $i<@sorted_list; $i++)
	{
		$seq_coverage_percent = ($align_len[$sorted_list_index[$i]]/$Query_length)*100; 
		&alignment_color($bit_score[$sorted_list_index[$i]]);
		if($sorted_list[$i] < $EVALUE)
		{
			if($seq_coverage_percent > $PERCENT_COVERAGE)
			{
				push(@check, $pdb[$sorted_list_index[$i]]);
				last;
			} 

		}
	}


	if(@check){
		print "$line. $file: AHEMODEL JOB\n";
	}
	else{
		print "$line. $file: QUARK JOB\n";
		push(@line_check, "$line "); 
	}
$line++; 
}

open(O, ">quark_domains.txt"); 
#if(@line_check)
#{
	print O (@line_check);
#}
#print(scalar @line_check);


sub sort {

	(@abc) = @_;
	$l = 0;

	@temp_abc = map { {value=>$_, index=>$l++} } @abc;
	@sorted_temp_abc = sort { $a->{value} <=> $b->{value} } @temp_abc; 
	@sorted_list = map { $_->{value} } @sorted_temp_abc;
	@sorted_list_index = map { $_->{index} } @sorted_temp_abc;
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
