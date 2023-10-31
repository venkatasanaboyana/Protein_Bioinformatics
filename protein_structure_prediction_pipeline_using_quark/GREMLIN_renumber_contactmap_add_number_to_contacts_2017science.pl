#!/usr/bin/perl
#This script is implemented to renumber the contact maps that are generated from "extract_top_cm_restraints.py". It creates a contact map that maps the contacts correctly with actual protein/query sequence. This script also calculates the normalized score using "Score =  ((raw_sco - min_sco)/(avg_sco - min_sco))/2 + 0.5" where raw score is directly reported from gremlin. The ranking is based on the Score that is calculated and first 3L/2 contacts (length is the length of consensus in query_id90cov75.cut (2nd line)) are present in the output file. This was modified 05/14/2019. 
#Protein structure determination using metagenome sequence data
#Sergey Ovchinnikov, Hahnbeom Park, Neha Varghese, Po-Ssu Huang, Georgios A. Pavlopoulos, David E. Kim, Hetunandan Kamisetty, Nikos C. Kyrpides, David Baker
#
#Usage:./GREMLIN_renumber_contactmap_add_number_to_contacts.pl query_id90cov75.cut matlab_input_all_pairs.cst Protein_length 
#We can also add fourth argument: which a number to add to the residues. This is useful when you have run gremlin on a particular domain.  

use List::Util qw( min max );

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

open(output, ">renumbered_gremlin_raw_scores_scaled_scores_within_3l_over_2_contactmap.txt");
open(output2, ">renumbered_gremlin_raw_scores_scaled_scores_within_3l_over_2_restraints_input.txt"); 
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
}
$length_consensus = $non_gap; 

for($i=0; $i<@gremlin_cont1; $i++)
{
	if($i < 1.5 * $length_consensus)
	{
		push(@raw_scores_lt_3l2, $gremlin_scores[$i]);
		$score_sum = $score_sum + $gremlin_scores[$i]; 
	}
}
$gremlin_score_avg = $score_sum / (1.5 * $length_consensus);
$min_score = min @raw_scores_lt_3l2; 
$max_score = max @raw_scores_lt_3l2; 

for($i=0; $i<@gremlin_cont1; $i++)
{	
	$scaled_score = (($gremlin_scores[$i]-$min_score)/($gremlin_score_avg - $min_score))/2 + 0.5;
	if($i < 1.5 * $length_consensus){  #prints number of contacts not more than 50% the length of protein
	print output ($renumber_cont1[$i] + $add, "\t", $renumber_cont2[$i] + $add, "\t", $scaled_score,"\n"); 
	 print output2 ($renumber_cont1[$i] + $add, "\t", $renumber_cont2[$i] + $add, "\t",$scaled_score,"\n");
	print output ($renumber_cont2[$i] + $add, "\t", $renumber_cont1[$i] + $add, "\t", $scaled_score,"\n");
	}
}
