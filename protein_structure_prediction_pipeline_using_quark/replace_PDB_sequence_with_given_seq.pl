#!/usr/bin/perl

$file = $ARGV[0] || die("Please enter your pdb file as your first arg\n"); 
$chain = $ARGV[1] || die("Please provide chain identifier\n"); 
$start_resid = $ARGV[2] || die("Please provide starting residue\n"); 
open(input, "$file");
@input_pdb = <input>; 
chomp(@input_pdb); 

print("Paste the sequence to replace the PDB sequence: \n"); 
$sequence = <STDIN>; 
chomp($sequence);
@seq_split = split(//, $sequence); 

$count = $start_resid-1; 

open(output, ">Sequence_replaced_renumbered.pdb");

foreach $line (@input_pdb)
{
	@split_PDB = split(/ +/, $line); 
	if($split_PDB[0] =~ "ATOM")
	{
		if($split_PDB[2] =~ "N")
	   	{
			$count++;
			&seq($seq_split[$count-$start_resid]);
			$new_seq = $replace; 
		}
		if($split_PDB[4] =~ /^\d+?$/)
		{ 
	   		printf output ("ATOM%7d  %-3s%4s%2s%4d%12.3f%8.3f%8.3f 50.00  0.00\n",$split_PDB[1],$split_PDB[2],$new_seq,$chain,$count,$split_PDB[5], $split_PDB[6], $split_PDB[7]);	
		}
		else{
			printf output ("ATOM%7d  %-3s%4s%2s%4d%12.3f%8.3f%8.3f 50.00  0.00\n",$split_PDB[1],$split_PDB[2],$new_seq,$chain,$count,$split_PDB[6], $split_PDB[7], $split_PDB[8]);
		
		}

	}
}
sub seq {
	($a) = @_; 
        if($a =~ 'D')
	{
		$replace = "ASP"; 
	}
	if($a =~ 'T')
        {
                $replace = "THR";
        }
        if($a =~ 'S')
        {
                $replace = "SER";
        }
        if($a =~ 'E')
        {
                $replace = "GLU";
        }
        if($a =~ 'P')
        {
                $replace = "PRO";
        }
	if($a =~ 'G')
        {
                $replace = "GLY";
        }
        if($a =~ 'A')
        {
                $replace = "ALA";
        }
        if($a =~ 'C')
        {
                $replace = "CYS";
        }
        if($a =~ 'V')
        {
                $replace = "VAL";
        }
        if($a =~ 'M')
        {
                $replace = "MET";
        }
        if($a =~ 'I')
        {
                $replace = "ILE";
        }
        if($a =~ 'L')
        {
                $replace = "LEU";
        }
        if($a =~ 'Y')
        {
                $replace = "TYR";
        }
        if($a =~ 'F')
        {
                $replace = "PHE";
        }
        if($a =~ 'H')
        {
                $replace = "HIS";
        }
        if($a =~ 'K')
        {
                $replace = "LYS";
        }
        if($a =~ 'R')
        {
                $replace = "ARG";
        }
        if($a =~ 'W')
        {
                $replace = "TRP";
        }
        if($a =~ 'Q')
        {
                $replace = "GLN";
        }
        if($a =~ 'N')
        {
                $replace = "ASN";
        }


}
