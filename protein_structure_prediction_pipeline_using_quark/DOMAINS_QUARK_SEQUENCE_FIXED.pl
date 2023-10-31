#!/usr/bin/perl
use POSIX; 
$file 		= $ARGV[0]; 	#input file name
	
open(boundary, "$file.boundary") || die("could not locate the boundary file");
@boundary_contents = <boundary>;
$line_num=0;
foreach $newline (@boundary_contents)              #Saves the domain boundaries in domain_boundary
	{
		@SPLIT = split(/ /, $newline);
		$line_num = $line_num + 1;
		if($line_num == 2)
		{
			$number_domains = $SPLIT[6];
		}
		if($line_num == 3)
		{	
			for($i=0; $i<$number_domains-1; $i++)
			{
				push(@domain_boundary, $SPLIT[$i+5]);
			}
		}
	}

open(secpred, "$file.pred") || die("could not open *.pred file");
@sec = <secpred>;
$line_num=0;
foreach $newline (@sec)
	{	
		$line_num = $line_num + 1;
		if($line_num == 2)
		{	
			$line2 = $newline;
		} 	
		if($line_num == 3)
		{	
			$line3 = $newline;
		}
	}
	
	@SEQUENCE = split(//, $line2);  	#protein sequence
	@SECSTRUCT = split(//, $line3); 	#protein secondary content
        splice @SEQUENCE, 0, 0, '0';		#inserted zero at the starting position of the array	
        splice @SECSTRUCT, 0, 0, '0';           #makes easier for the array comparision. 
	chomp(@SEQUENCE); 			#removes the last character in the array
	chomp(@SECSTRUCT);

##########CHOPPING THE BOUNDARY EDGES#######################
$length  = scalar @SECSTRUCT;

for($i=1; $i<$length-1; $i++)                  #chopping off the coiled region on the first edge       
{
	if($SECSTRUCT[$i] !~ "C")
	{
		push(@boundary_chopped, $i);
		last if $SECSTRUCT[$i] !~ "C";	
	}
}
for($i= $length-1; $i>=0; $i--)
{
       if($SECSTRUCT[$i] !~ "C")
	{
		push(@boundary_chopped, $i);
		last if $SECSTRUCT[$i] !~ "C";
	}
}
#########################################################
#$sec_count =0;
#for($i=0; $i<@SECSTRUCT; $i++)
#{
#  	if($SECSTRUCT[$i] !~ 'C')
#	{
#		$sec_count++;
#	}
#	else{
#		push(@sec_struct_count, $sec_count);
#		$sec_count=0; 
#	}
#
#}
#&sort(@sec_struct_count); 
#$longest_sec_element = $sorted_list[0]; 
###############CHOPPING AT THE LOCATIONS PREDICTED BY DOMPRED##############
push(@DOMAINS_temp, $boundary_chopped[0]);
for($i=0; $i<@domain_boundary; $i++)
{
		push(@DOMAINS_temp, $domain_boundary[$i]);
}
push(@DOMAINS_temp, $boundary_chopped[1]);
########################Removing the preexisting file#######################################################
if (-e "$file.domain_list.txt")
{
	unlink "$file.domain_list.txt"; 
}
####################################dividing a domain>200 into two equal domains#############################

for($i=1; $i<@DOMAINS_temp;$i++)
{
	$check = 0; $temp_modify = 1; 
	$domain_length = $DOMAINS_temp[$i]-$DOMAINS_temp[$i-1];
	if($domain_length <= 210)
	{
		if($i<scalar @DOMAINS_temp - 1) 
		{
			&find_boundary($DOMAINS_temp[$i]);
			if($DOMAINS_ready[0]-$DOMAINS_temp[$i-1] <= 200)
			{
				print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1],"\n");
				print("domain ",$i,"ends at \t:",$DOMAINS_ready[0],"\n");
				$domain_name = $i;
				&seq($DOMAINS_temp[$i-1],$DOMAINS_ready[0]);
				
			}
			else{
				$check = 1; 
				&find_boundary($DOMAINS_temp[$i]);
				$domain_length_temp = $DOMAINS_ready[0]-$DOMAINS_temp[$i-1];
				if($DOMAINS_ready[0]-$DOMAINS_temp[$i-1] <= 200)
				{
					print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1],"\n");
					print("domain ",$i,"ends at \t:",$DOMAINS_ready[0],"\n");
					$domain_name = $i;
					&seq($DOMAINS_temp[$i-1],$DOMAINS_ready[0]);
				}
				else{
					$modify = ceil(($domain_length_temp-200)/2);
					print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1]+$modify,"\n");
					print("domain ",$i,"ends at \t:",$DOMAINS_ready[0]-$modify,"\n");
					$domain_name = $i;
					&seq($DOMAINS_temp[$i-1]+$modify,$DOMAINS_ready[0]-$modify);
				}
			}
			
				
		}
		if($i == scalar @DOMAINS_temp - 1) 
		{
			$last_domain_length = $DOMAINS_temp[-1]-$DOMAINS_temp[$i-1]; 
			if($last_domain_length <= 200)
			{
				print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1],"\n");
				print("domain ",$i,"ends at \t:",$DOMAINS_temp[-1],"\n");
				$domain_name = $i;
				&seq($DOMAINS_temp[$i-1],$DOMAINS_temp[-1]);
			}
			else{

				$modify = ceil(($last_domain_length-200)/2);
				print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1]+$modify,"\n");
				print("domain ",$i,"ends at \t:",$DOMAINS_temp[-1]-$modify,"\n");
				$domain_name = $i;
				&seq($DOMAINS_temp[$i-1]+$modify,$DOMAINS_temp[-1]-$modify);
			}
			
			
		}
	}
	
	if($domain_length >210)
	{
		if($i<((scalar @DOMAINS_temp) - 1))
                {

			&find_boundary($DOMAINS_temp[$i]); 
			$first = $DOMAINS_temp[$i-1];  
			$second = $DOMAINS_ready[0];
			if($DOMAINS_ready[0]-$DOMAINS_temp[$i-1]<=210)
			{	
				if($DOMAINS_ready[0]-$DOMAINS_temp[$i-1]<=200)
				{
                        	       	 print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1],"\n");
                               		 print("domain ",$i,"ends at \t:",$DOMAINS_ready[0],"\n");
					 $domain_name = $i; 
					 &seq($DOMAINS_temp[$i-1],$DOMAINS_ready[0]);
				}
                       		else{
                                	$check = 1;
                               		&find_boundary($DOMAINS_temp[$i]);
                               		 if($DOMAINS_ready[0]-$DOMAINS_temp[$i-1] <= 200)
                               		 {
                                       		 print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1],"\n");
                                       		 print("domain ",$i,"ends at \t:",$DOMAINS_ready[0],"\n");
						 $domain_name = $i;
						 &seq($DOMAINS_temp[$i-1],$DOMAINS_ready[0]);
                               		 }
                              		 else{
                                       		 $modify = ceil((($DOMAINS_ready[0]-$DOMAINS_temp[$i-1])-200)/2);
                                      		 print("domain ",$i,"starts at \t:",$DOMAINS_temp[$i-1]+$modify,"\n");
                                       		 print("domain ",$i,"ends at \t:",$DOMAINS_ready[0]-$modify,"\n");
						 $domain_name = $i;
						 &seq($DOMAINS_temp[$i-1]+$modify, $DOMAINS_ready[0]-$modify);
                               		 }
				}
                        }
			else{
				$n=1;
				do {
				&local_maxima($first,$second);
                                print("domain ",$i,".$n starts at  \t:", $first, "\n");
                                print("domain ",$i,".$n ends at  \t:", $new_boundary_end, "\n");
                                $domain_name = "$i.$n";
                                &seq($first,$new_boundary_end);
				$n++; 
				if($second - $new_boundary_start <= 200)
                                {
                                        print("domain ",$i,".$n starts at  \t:", $new_boundary_start, "\n");
                                        print("domain ",$i,".$n ends at  \t:", $second, "\n");
                                        $domain_name = "$i.$n";
                                        &seq($new_boundary_start,$second);

                                }
				$first  = $new_boundary_start; 
				if($n > 10)
                                {
                                        print "\n############\nBOUNDARY MUST BE WITHIN AN SS ELEMENT THAT IS MORE THAN 200 RESIDUE LONG\n";
                                        print "TERMINATING\n";
                                        exit 1;
                                }
				} while($second - $first > 200 )
			}
		}
		if($i == (scalar @DOMAINS_temp) - 1)
		{
			
		#	&find_boundary($DOMAINS_temp[$i]); 
			$first = $DOMAINS_temp[$i-1];  
			$second = $DOMAINS_temp[-1];
		
			$n=1;
                        do {
                 	        &local_maxima($first,$second);
                                print("domain ",$i,".$n starts at  \t:", $first, "\n");
                                print("domain ",$i,".$n ends at  \t:", $new_boundary_end, "\n");
                                $domain_name = "$i.$n";
                                &seq($first,$new_boundary_end);
                                $n++;
                                if($second - $new_boundary_start <= 200)
                                {
                                        print("domain ",$i,".$n starts at  \t:", $new_boundary_start, "\n");
                                        print("domain ",$i,".$n ends at  \t:", $second, "\n");
                                        $domain_name = "$i.$n";
                                        &seq($new_boundary_start,$second);

                                }
                                $first  = $new_boundary_start;
				if($n > 10)
				{
					print "\n##########\nBOUNDARY MUST BE WITHIN AN SS ELEMENT THAT IS MORE THAN 200 RESIDUES LONG\n"; 
					print "TERMINATING\n"; 
					exit 1; 
				}
                           } while($second - $first > 200 )
			
					
		}
			
	}
		
}


sub find_boundary {

	($value) = @_;
	@upward = ();
	@downward = ();
	@upward_C = ();
	@downward_C = ();
	@upward_extend = ();
	@downward_extend = ();
	
	 if($SECSTRUCT[$value] =~ "C")
        {
                $boundary = $value;
                do {
                        push(@downward_C, $boundary);
                        $boundary = $boundary - 1;
                } while($SECSTRUCT[$boundary] =~ "C");

                $boundary = $value;
                do {
                        push(@upward_C, $boundary);
                        $boundary = $boundary + 1;
                } while($SECSTRUCT[$boundary] =~ "C");
		
		if($upward_C[-1]-$downward_C[-1]>5)
		{
                 	$DOMAINS_ready[0] = $downward_C[-1];
		 	$DOMAINS_ready[1] = $upward_C[-1];
	   	}
		if($upward_C[-1]-$downward_C[-1]<=5)
		{
			$DOMAINS_ready[1] = $upward_C[-1];
			$DOMAINS_ready[0] = $upward_C[-1]-5;

		}
        }
		#if the domain boundary is in between the secondary structure		
		#then slide upward or downward depending on length

	if($SECSTRUCT[$value] !~ "C")		
	{
		$boundary = $value;
		do {
			push(@downward, $boundary);	
			$boundary = $boundary - 1;	
		} while($SECSTRUCT[$boundary] !~ "C");

		do {
                        push(@downward_extend, $boundary);
                        $boundary = $boundary - 1;
                } while($SECSTRUCT[$boundary] =~ "C");


		$boundary = $value;
		do {
                        push(@upward, $boundary);
                        $boundary = $boundary + 1;
                } while($SECSTRUCT[$boundary] !~ "C");

                do {
                        push(@upward_extend, $boundary);
                        $boundary = $boundary + 1;
                } while($SECSTRUCT[$boundary] =~ "C");


		$upward_length = scalar @upward;
		$downward_length = scalar @downward;
		if ($check == 0)
		{
			if($upward_length < $downward_length)
			{
				if(($upward_extend[-1]-$upward[-1])>5) 
				{	
	                        	$DOMAINS_ready[0] = $upward[-1];
	                        	$DOMAINS_ready[1] = $upward_extend[-1];
				}
				if(($upward_extend[-1]-$upward[-1])<=5)
				{
                 			$DOMAINS_ready[0] = $upward[-1];
                 			$DOMAINS_ready[1] = $upward[-1]+5;
				}
			}
			else{
				if(($downward[-1]-$downward_extend[-1])>5)
				{
					$DOMAINS_ready[0] = $downward_extend[-1];
					$DOMAINS_ready[1] = $downward[-1];
				}
				if(($downward[-1]-$downward_extend[-1])<=5)
				{
					$DOMAINS_ready[0] = $downward[-1]-5;
					$DOMAINS_ready[1] = $downward[-1];
				}
			}
			
		}
		else
		{
			if(($downward[-1]-$downward_extend[-1])>5)
			{
                 		$DOMAINS_ready[0] = $downward_extend[-1];
                 		$DOMAINS_ready[1] = $downward[-1];
			}
			if(($downward[-1]-$downward_extend[-1])<=5)
			{
				$DOMAINS_ready[0] = $downward[-1]-5;
				$DOMAINS_ready[1] = $downward[-1];
			}
                 		
		}
	}
        if($temp_modify == 1)
	{
		$DOMAINS_temp[$i] = $DOMAINS_ready[1]; 
	}
}

sub local_maxima {
	@domain_a = ();
	@termini_domain = ();
	@index = ();
	@termini = ();
	@helix = ();
	@beta = ();
	@coil = ();
	$temp_modify = 0; 
	($value1, $value2) = @_;
	open(input, "$file.graph") || die("could not locate the graph file");
	@graph = <input>;
	foreach $line (@graph)
	{
		@each = split(/ /,$line);
		push(@index, $each[0]);
		push(@termini, $each[1]);
		push(@helix, $each[2]);
		push(@beta, $each[3]);
		push(@coil, $each[4]);

	}
	$value1_index = $value1 - $index[0];
	$value2_index = $value2 - $index[0];
	for($j=$value1_index; $j<$value2_index; $j++)
	{
		push(@termini_domain, $termini[$j]);	#largest domain is pushed into termini_domain for sorting step	
	}
	&sort(@termini_domain);
	for($length=0;$length<@sorted_list;$length++) #sorted list and sorted index list are the output sorted arrays from sort sub; 
	{
		if($sorted_list_index[$length]>72 && $sorted_list_index[$length]<=200)
		{			
				push(@domain_a, $sorted_list_index[$length]+$value1);				
		}		
	}
	for($dl=0; $dl<@domain_a; $dl++)
	{
		&find_boundary($domain_a[$dl]);
		$v1 = $DOMAINS_ready[0]; $v2 = $DOMAINS_ready[1];
		if($v1-$value1>=72 && $v1-$value1<=200)
		{
			if($value2-$v2>=72)
			{
				
				#splice @DOMAINS_temp, $i+1, 0, $domain_a[$dl];   
				$new_boundary_end = $v1;
				$new_boundary_start = $v2;
				$dl = scalar @domain_a;
			}

		}
	}
}

sub sort {

 	(@list) = @_;
	@temp_list = ();
	@sorted_temp_list = ();
	@sorted_list = ();
	@sorted_list_index = ();
	$k=0;
	@temp_list = map { {value=>$_, index=>$k++} } @list;
	@sorted_temp_list = sort { $b->{value} <=> $a->{value} } @temp_list;
	@sorted_list = map { $_->{value} } @sorted_temp_list;
	@sorted_list_index = map { $_->{index} } @sorted_temp_list; 	
}

sub seq {

	($seq_start, $seq_end) = @_;
	open(OUTPUT, ">$file.domain_$domain_name.fasta");
	print OUTPUT (">",$file,"_domain_",$domain_name,"[$seq_start, $seq_end]","\n");		
	$c=0;
	for($start =0; $start<@SEQUENCE; $start++)
	{       
		if($start>=$seq_start && $start<=$seq_end)
		{
			$c++; 
			print($SEQUENCE[$start]);
			print OUTPUT ($SEQUENCE[$start]);
			if($c == 60)
			{
				print "\n"; 
				print OUTPUT ("\n"); 
				$c = 0; 
			} 
		}
	}
	print("\n");
	open(OUTPUT_domain, ">>$file.domain_list.txt");
	print OUTPUT_domain ("$file.domain_$domain_name.fasta\n");	
}
