#!/usr/bin/perl
#This script is implemented to renumber the contact maps that are generated from "extract_top_cm_restraints.py". It creates a contact map that maps the contacts correctly with actual protein/query sequence. This script also calculates the normalized score using "Score =  ((raw_sco - min_sco)/(avg_sco - min_sco))/2 + 0.5" where raw score is directly reported from gremlin. The ranking is based on the Score that is calculated and first 3L/2 contacts (length is the length of consensus in query_id90cov75.cut (2nd line)) are present in the output file. This was modified 05/21/2019. 

#It also calculates gremlin restraints from scaled scores by using a sigmoidal function that was developed on 05/20/2019

#Neff/sqrt(len) : Neff is the neff value in Gremlin output. len is the length of consensus(no gaps) in query_id90cov75.cut 
#Protein structure determination using metagenome sequence data
#Sergey Ovchinnikov, Hahnbeom Park, Neha Varghese, Po-Ssu Huang, Georgios A. Pavlopoulos, David E. Kim, Hetunandan Kamisetty, Nikos C. Kyrpides, David Baker
#
#Usage:./GREMLIN_renumber_contactmap_add_number_to_contacts.pl query_id90cov75.cut Gremlin_raw_scores.cst 
#We can also add third argument: which a number to add to the residues. This is useful when you have run gremlin on a particular domain.  
use POSIX; 
use List::Util qw( min max );

$file = $ARGV[0] || die("please provide the input file\n"); 
$file1 = $ARGV[1] || die("please provide raw scores\n");  
$add = $ARGV[2]; 
open(input, "$file"); 
@Input = <input>; 
chomp(@Input); 

open(input2, "$file1"); 
@Input2 = <input2>; 
chomp(@Input2);  
$count = 0; 

open(output, ">renumbered_gremlin_raw_scores_scaled_scores_within_3l_over_2_contactmap.txt");
open(output2, ">renumbered_gremlin_raw_scores_scaled_scores_within_3l_over_2_restraints_input.txt"); 
open(output3, ">effective_sequences_per_sqrt_len.txt");
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
$num_restraints = ceil(1.5 * $length_consensus);  
#$Neff_double=`wc query_id80cov75.cut.fas | cut -d ' ' -f 3`; ##Modify this later because the value sometimes lies at -f 4. So use a better way to obtain Neff
#chomp($Neff_double); 
#print($Neff_double, "\n");

#$Neff = $Neff_double/2; #fas file gives the sequences along with its header 
$Neff=`grep "neff" gremlin_output | cut -d ' ' -f 6`; #Gremlin output
$score_sum =0; 
for($i=0; $i<@gremlin_cont1; $i++)
{
	if($i < $num_restraints)
	{
		push(@raw_scores_lt_3l2, $gremlin_scores[$i]);
		$score_sum = $score_sum + $gremlin_scores[$i]; 
	}
}
$gremlin_score_avg = $score_sum/$num_restraints;
$min_score = min @raw_scores_lt_3l2; #min of raw scores
$max_score = max @raw_scores_lt_3l2; 
for($i=0; $i<@gremlin_cont1; $i++)
{	
	$scaled_score = (($gremlin_scores[$i]-$min_score)/($gremlin_score_avg - $min_score))/2 + 0.5; #Obtained from Gremlin server 2017 metagenomics contacts prediction
	$Nf = $Neff/sqrt($length_consensus); #Obtained from Gremlin output
	$b = (3.9492 + 0.9391 * ($Nf) + 0.0044 * ($Nf)**2)/(1 + 1.7401 * ($Nf) + 0.0679 * ($Nf)**2); #function derived inhouse
	$x0 = (13.2214 + 2.9992 * ($Nf) + 0.0131 * ($Nf)**2)/(1 + 1.8707 * ($Nf) + 0.0781 * ($Nf)**2);#function derived inhouse
#	$Gremlin_restraint/$scaled_score = 1/(1+exp(-($scaled_score - $x0)/$b)); #Restraint function derived inhouse 
	
	$Gremlin_restraint = (1/(1+exp(-($scaled_score - $x0)/$b))) * $scaled_score; 
	if($i < $num_restraints){  #prints number of contacts with in 1.5 times effective length
       	 
#	print($Gremlin_restraint,"\n"); 	
	
	print output ($renumber_cont1[$i] + $add, "\t", $renumber_cont2[$i] + $add, "\t", $scaled_score,"\n"); 
	 print output2 ($renumber_cont1[$i] + $add, "\t", $renumber_cont2[$i] + $add, "\t",$Gremlin_restraint,"\n");
	print output ($renumber_cont2[$i] + $add, "\t", $renumber_cont1[$i] + $add, "\t", $scaled_score,"\n");
	}
}
print output3 ($Nf, "\n"); 
