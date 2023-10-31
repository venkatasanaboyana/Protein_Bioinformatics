#!/usr/bin/perl

$cutoff = 1.5; 
############################################################
$PDB = $ARGV[0]; 
@experiment = split(/ +/, $ARGV[1]);  
$PDB_chain = $ARGV[2] || die("please provide PDB chain\n"); 
if($experiment[-1] !~ "NMR")
{
	`cp /home/vsanaboyana/PhD/ECOLI_STRUCTURES/AIDA/ADDITIONAL_SOFTWARES/WHOLE_ASSEMBLY/extract_chosen_chains.* .`;
	`./extract_chosen_chains.exe $PDB.RCSB.pdb 1 $PDB_chain 0`;  
	`cp chains_extracted_and_renamed.pdb $PDB.model1.pdb`; 
	exit; 
}

############################################################

open(input, "$PDB.RCSB.pdb") || die("could not find the file\n"); 
@input_file = <input>; 
chomp(@input_file); 

open(output, ">$PDB.model1.pdb"); #NMR rigid domain



$i = 1; $count_line = 0;$num_models=0;  
foreach $line (@input_file)
{
	@split_lines_models = split(/ +/, $line);
	if($split_lines_models[0] =~ "MODEL")
	{
		$num_models++; 
	}

}

foreach $line (@input_file)
{
	@each_CA = (); 
	@split_lines = split(/ +/, $line);
	$count_line++;
	if($split_lines[0] =~ "ATOM" && $split_lines[2] =~ "CA" && $split_lines[5] == $i )
	{
		push(@each_CA, $split_lines[6]); 
		push(@each_CA, $split_lines[7]);
		push(@each_CA, $split_lines[8]);
		for($line_2 = $count_line; $line_2 < @input_file; $line_2++)
		{
			@split_lines_2 = split(/ +/, $input_file[$line_2]);
			if($split_lines_2[0] =~ "ATOM" && $split_lines_2[2] =~ "CA" && $split_lines_2[5] == $i)	
			{
				push(@each_CA, $split_lines_2[6]);
				push(@each_CA, $split_lines_2[7]);
				push(@each_CA, $split_lines_2[8]);
			}		
		}
		&average_CA(@each_CA);
		push(@average_CA, $x_avg);
		push(@average_CA, $y_avg);
		push(@average_CA, $z_avg);
		&deviation($x_avg,$y_avg,$z_avg, $split_lines[6], $split_lines[7], $split_lines[8]);
		$TOTAL_RMSD = $distance; 		
		for($line_2 = $count_line; $line_2 < @input_file; $line_2++)
                {
                        @split_lines_3 = split(/ +/, $input_file[$line_2]);
                        if($split_lines_2[0] =~ "ATOM" && $split_lines_2[2] =~ "CA" && $split_lines_2[5] == $i)
                        {
                                push(@each_CA, $split_lines_2[6]);
                                push(@each_CA, $split_lines_2[7]);
                                push(@each_CA, $split_lines_2[8]);
				&deviation($x_avg,$y_avg,$z_avg, $split_lines_2[6], $split_lines_2[7], $split_lines_2[8]);
				$TOTAL_RMSD = $TOTAL_RMSD + $distance;
                        }
                }
		$RMSD_ATOM = sqrt($TOTAL_RMSD/$num_models);
#		print($i,"\t",$RMSD_ATOM, "\n");			
		if($RMSD_ATOM < $cutoff)
		{
			push(@rigid_boundaries, $split_lines[5]); 
			$rigid_start = $split_lines[5];  
		}
		else
		{
			$rigid_start = 0; 
		}
		push(@RMSD_EACH_CA, $RMSD_ATOM);
		$i++; 
		last if($split_lines[0] =~ "MODEL" && $split_lines[1] == 2); 
	}

	

}


for($i=0; $i<@rigid_boundaries; $i++)
{	
	$count =0; 
	foreach $line (@input_file)
	{
		$count++; 
		if($line =~ "MODEL        1")
		{
			$model_start = $count; 
		}
		if($line =~ "MODEL        2")
		{
			 $model_end = $count;
		}
	}
	$count = 0; 
	foreach $line (@input_file)
	{
		$count++; 
		@split_lines_4 = split(/ +/, $line);	
		if($count > $model_start && $count < $model_end ) 
		{
			if($split_lines_4[0] =~ "ATOM" && $split_lines_4[5] == $rigid_boundaries[$i])
			{
				print output ($line, "\n"); 
			}  
		}

	}	
}
#@average_CA, "\n"); 

sub average_CA {

	(@array) = @_; 
	$x=0; $y=0; $z=0; $count=0; 
	for($a=0; $a< scalar @array - 2; $a = $a + 3)
	{
		if($a == 3*$count) {
			$x = $array[$a] + $x; 
			$y = $array[$a+1] + $y;
			$z = $array[$a+2] + $z;  
		}
		$count++; 
		
	}
	$x_avg = $x/$num_models; 
	$y_avg = $y/$num_models;
	$z_avg = $z/$num_models;

}

sub deviation {
	($x1, $y1, $z1, $x2, $y2, $z2) = @_; 
	$distance = ($x2-$x1)**2 + ($y2-$y1)**2 + ($z2-$z1)**2; 

}
