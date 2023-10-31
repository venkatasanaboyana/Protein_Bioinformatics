#!/usr/bin/perl
#This script is implemented to renumber the contact maps that are generated from "extract_top_cm_restraints.py". It creates a contact map that maps the contacts correctly with actual protein/query sequence. This script also calculates the normalized score using "Score = (raw_score/average(raw_scores))" where raw score is directly reported from gremlin. The ranking is based on the Score that is calculated and first 3L/2 contacts are present in the output file. This was modified 05/14/2019. 
#The reference: Robust and accurate prediction of residue-residue interactions across protein interfaces using evolutionary information.Sergey Ovchinnikov, Hetunandan Kamisetty, and David Baker. 
#Elife (2014)
#
#Usage:./GREMLIN_renumber_contactmap_add_number_to_contacts.pl query_id90cov75.cut matlab_input_all_pairs.cst Protein_length
#We can also add fourth argument: which a number to add to the residues. This is useful when you have run gremlin on a particular domain.  

$file = $ARGV[0] || die("please provide the input file\n"); 
$file1 = $ARGV[1] || die("please provide matlab input file\n"); 
$length = $ARGV[2] || die("enter the length of protein\n"); 
$add = $ARGV[3]; 
open(input, "$file"); 
@Input = <input>; 
chomp(@Input); 

open(input2, "$file1"); 
@Input2 = <input2>; 
chomp(@Input2);  
$count = 0; 

open(output, ">renumbered_gremlin_raw_scores_scaled_scores_gt1_.txt"); 
foreach $line (@Input)
{
	$count++; 
	@sequences = split(//, $line); 
	if($count == 1)
	{
		for($c=0; $c<@sequences; $c++)
                {
                        push(@query, $sequences[$c]);
                }

	}
	if($count == 2)
	{
		for($c=0; $c<@sequences; $c++)
		{
			push(@consensus, $sequences[$c]);
		}
	}

}
chomp(@query); 
chomp(@consensus); 
foreach $line (@Input2)
{
	@split_input2 = split(/ +/, $line); 
	push(@gremlin_cont1, $split_input2[0]);
	push(@gremlin_cont2, $split_input2[1]); 
	push(@gremlin_scores, $split_input2[2]); 

}
chomp(@gremlin_cont1); 
chomp(@gremlin_cont2);
chomp(@gremlin_scores);
$score_avg = 0; 
$count = 0; 
for($i=0; $i<scalar @gremlin_cont1; $i++)
{
	$non_gap = 0; 
	for($j=0; $j<@consensus; $j++)
	{
		if($consensus[$j] !~ '-')
		{
			$non_gap++; 	
		}
		if($gremlin_cont1[$i] == $non_gap)
		{
			push(@renumber_cont1, $j+1);
		}
		if($gremlin_cont2[$i] == $non_gap)
                {
                        push(@renumber_cont2, $j+1);
                }


	}
	$count++; 
	if($count <= 1.5 * $length)
	{
		$score_avg = $score_avg + $gremlin_scores[$i]; 
	}
}
$gremlin_score_avg = $score_avg / (1.5 * $length);
#print(scalar @renumber_cont1, "\n"); 
#print(scalar @renumber_cont2, "\n");
print($gremlin_score_avg, "\n");
#for($i=0; $i<@renumber_cont1; $i++)
for($i=0; $i<@gremlin_cont1; $i++)
{
	$scaled_score = $gremlin_scores[$i]/$gremlin_score_avg;
	if($scaled_score >=  1){  #prints number of contacts not more than 50% the length of protein
	print output ($renumber_cont1[$i] + $add, "\t", $renumber_cont2[$i] + $add, "\t", $gremlin_scores[$i],"\n"); 
	print output ($renumber_cont2[$i] + $add, "\t", $renumber_cont1[$i] + $add, "\t", $gremlin_scores[$i],"\n");
	}
}
