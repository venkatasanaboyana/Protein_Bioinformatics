#!/usr/bin/perl
#This script was written on 05/14/2019 to generate Rosetta specific restraints to be used for Rosetta ab initio structure prediction. The script generate 3L/2 restraints (where L is the length of consensus sequence in query_id90cov75.cut). 

$fasta = $ARGV[0]; 
$res_pairs = $ARGV[1];
$format = $ARGV[2]; 

  $argc = $#ARGV + 1; 

if($argc < 3) 
	{
		print "\n-----USAGE ERROR-----\n";
		print "./CONVERT_LOCAL_TO_SERVER_FORMAT.pl *.fasta renumbered_gremlin_raw_scores_scaled_scores_within_3l_over_2_restraints_input.txt local_restraint_all_pairs.cst\n"; 
		print "**************\n"; 
		print "*.fasta includes fasta sequence of the query,\n"; 
		print " renumbered_gremlin_raw_scores_scaled_scores_within_3l_over_2_restraints_input.txt is the output of *GREMLIN_renumber_contactmap_add_number_to_contacts_2017science.pl* script"; 
		print "local_restraint_all_pairs.cst is the output of 'extract_top_cm_restraints.py'script.\n";
		print "Remeber to copy sigmoidal_values.csv file to the current working directory.\n";
		print "All these scripts are located at ** /home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/ **."; 
		print "**************\n"; 
		
		exit 1;
}
open(fas, "$fasta"); 
@sequence_info = <fas>; 
chomp(@sequence_info); 

open(resid_pairs, "$res_pairs"); 
@res_pair = <resid_pairs>; 
chomp(@res_pair);

open(res_form, "$format"); 
@res_format = <res_form>; 
chomp(@res_format); 

open(sig, "sigmoidal_values.csv") || die("should contain sigmoidal_values.csv file in this folder\n"); 
@sigmoidal_values = <sig>; 
chomp(@sigmoidal_values);   

open(OUTPUT, ">Gremlin_restraints_2017.cst"); 
foreach $line (@sequence_info)
{
	if($line !~ ">")
	{ 
        	@seq_split = split //, $line; 
	}
push(@seq_res, @seq_split); 
}

for($a=0; $a<@res_pair; $a++)
{
	@res_pair_split = split(/\t/, $res_pair[$a]);
#	print($res_pair_split[0],"\t",$res_pair_split[1], "\t", $res_pair_split[2],"\n"); 
	&cutoff_prob($seq_res[$res_pair_split[0]-1], $seq_res[$res_pair_split[1]-1]);  
	#print($res_pair_split[0], "\t", $seq_res[$res_pair_split[0]-1],"\t", $res_pair_split[1], "\t", $seq_res[$res_pair_split[1]-1], "\n"); 
	$inv_slope = 1/$slope; 
	@restraints_format = split(/ +/, $res_format[$a]);
	$text="SUMFUNC 2";  
	printf OUTPUT ("%s %s %d %s %d %s %0.3f %s %s %0.3f ",$restraints_format[0],$restraints_format[1],$res_pair_split[0],$restraints_format[3],$res_pair_split[1],$restraints_format[5],$res_pair_split[2], $text, $restraints_format[7],$cutoff); 
        printf OUTPUT ("%.3f CONSTANTFUNC -0.5\n", $inv_slope);
}

sub cutoff_prob { 

	($value1, $value2) = @_;
	$row =0; 
	foreach $line (@sigmoidal_values)
	{
		@cutoff = split(/\t+/, $line); 
		if($row == 0){
			@residues = @cutoff; }
		for($i=0; $i<@cutoff; $i++)
		{
			$MAT[$row][$i] = $cutoff[$i]; 
		}
	$row++; 
	}
	$index_res1 = 0; 
	++$index_res1 until $residues[$index_res1] =~ $value1; 
	$index_res2 = 0;
	++$index_res2 until $residues[$index_res2] =~ $value2;  
	if($MAT[$index_res2+1][$index_res1] > 1){
		$cutoff = $MAT[$index_res2+1][$index_res1];
		$slope = $MAT[$index_res1+2][$index_res2]; 
	}
	else{
		$cutoff = $MAT[$index_res1+1][$index_res2]; 
		$slope = $MAT[$index_res2+2][$index_res1]; 
	}
}
