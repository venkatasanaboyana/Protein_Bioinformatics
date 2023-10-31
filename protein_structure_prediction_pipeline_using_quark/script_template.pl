#!/usr/bin/perl

$EVALUE = 1.0e-20;
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


$file = $ARGV[0] || die "please provide the fasta file\n"; 
$uniprot = $ARGV[1] || die "Please provide the uniprot\n";
$user = $ARGV[2] || die "please provide the username for the machine\n"; 
$directory = $ARGV[3] || die "please provide the directory you named\n";
$username = $ARGV[4] || die "please provide quark username\n"; 
$password = $ARGV[5] || die "please provide quark password\n"; 

print "submitting the $file to seq atoms\n"; 
	`perl submit_seqatoms.pl $file > seqatoms_output`;


print "processing the seq_atom output file\n";
open (input, "seqatoms_output") || die ("could not locate seqatoms_output file\n");
@seq_atoms_xml = <input>; 
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
				push(@chain, $split_line[5]); 
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
			print("\n\nTEMPLATE DETAILS: \n");
			print("PDB SELECTED IS :\t", $pdb[$sorted_list_index[$i]],"\n");
			print("EVALUE IS :\t\t", $sorted_list[$i],"\n");
			print("SEQ COVERAGE IS :\t", $seq_coverage_percent,"\n");
			print("ALIGNMENT COLOR IS :\t", $color,"\n\n");
			$j = $i; 
			last;
		} 

	}
}


$filename_pdb=`echo "$file" | rev | cut -c 7- | rev`;
chomp($filename_pdb);
if(@check){
	print "DOMAIN WILL BE SUBMITTED FOR AHEMODEL BUILDING\n";
	`ssh $user\@$IP "cd /home/$user/$directory/$uniprot;cp /home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/SUBMIT_AHEMODEL.sh .;bash SUBMIT_AHEMODEL.sh $pdb[$sorted_list_index[$j]] $chain[$sorted_list_index[$j]] $file"`; 
	
}
else{
	print "\n\nNO HOMOLOGOUS TEMPLATE AVAILABLE, THEREFORE CANNOT BE SUBMITTED FOR AHEMODEL BUILDING\n";
	print "DOMAIN WILL BE SUBMITTED FOR QUARK\n";
	`./SUBMIT_QUARK.sh $file $username $password`; 
}


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
