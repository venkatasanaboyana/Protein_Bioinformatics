#!/usr/bin/perl
##Usage:./generate_Gaussian_restraints.pl $value  
#This will generate restraints by accounting weights to be probabilities multiplied by the value strength
#./generate_Gaussian_restraints.pl zero ! for no weights
#Make sure query.fasta and dist.txt are located in the same folder


$value = $ARGV[0] || die("please provide the strength\n");

open(input, "dist.txt") || die("could not locate dist.txt file\n"); 
@array = <input>; 
chomp(@array); 

open(input2, "query.fasta") || die("could not locate query.fasta file\n"); 
@seq = <input2>;
chomp(@seq); 

#Reading fasta
for($i=0; $i<@seq; $i++)
{
	if($seq[$i] !~ ">")
	{
		@seq_split = split( //, $seq[$i]);
		push(@seq_res, @seq_split); 
	}

} 

#Reading dist.txt
foreach $line (@array)
{
	@array_split = split(/ +/, $line); 
	if($seq_res[$array_split[0]-1] =~ 'G')
	{
		$sidechain1 = 'CA';  
	}
	else{
		$sidechain1 = 'CB'
	}
	
	if($seq_res[$array_split[1]-1] =~ 'G')
        {
                $sidechain2 = 'CA';
        }
        else{
                $sidechain2 = 'CB';
        }
	if($value =~ "zero")
	{
		 print("AtomPair $sidechain1 $array_split[0] $sidechain2 $array_split[1] GAUSSIANFUNC $array_split[3] $array_split[4] TAG\n");
	}
	else
	{
		$weight = $value * $array_split[2]; 
		print("AtomPair $sidechain1 $array_split[0] $sidechain2 $array_split[1] GAUSSIANFUNC $array_split[3] $array_split[4] TAG WEIGHT $weight\n")
	}
		
}
