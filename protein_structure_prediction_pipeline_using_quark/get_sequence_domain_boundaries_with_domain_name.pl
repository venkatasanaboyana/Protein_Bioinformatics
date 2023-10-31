#!/usr/bin/perl

##This scirpt has been modified to include domain name
$file = $ARGV[0];
$start = $ARGV[1]; 
$end = $ARGV[2]; 
$domain_name =  $ARGV[3];
$filename=`echo "$file" | rev | cut -c 7- | rev`;
chomp($filename);
&sequence($start, $end); 
sub sequence {

        ($start, $end) = @_;
        open(output, ">$filename.$domain_name.$start-$end.fasta");
        print output (">$file.$domain_name\[$start, $end\]\n");
        open(input, "$file") || die("could not find the sequence file\n");
        @seq_file = <input>;
        chomp(@seq_file);
        foreach $line (@seq_file)
        {
                if($line !~ ">")
                {
                        chomp($line);
                        @split_char = split(//, $line);
                        for($c1=0; $c1<@split_char; $c1++)
                        {
                                push(@seq, $split_char[$c1]);
                        }

                }
        }
        $n=0;
        for($c = 0; $c < @seq; $c++)
        {
                if($c >= $start-1 && $c <= $end-1)
                {
                        print output ($seq[$c]);
                        $n++;
                }
                if($n == 60)
                {
                        print output ("\n");
                        $n=0;
                }
        }

}

