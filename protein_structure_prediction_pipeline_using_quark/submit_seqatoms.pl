#!/usr/bin/perl 

use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);


my $file = $ARGV[0] or die "Provide the filename of your sequence file as argument:\n perl $0 <filename>\n";

my $ua = LWP::UserAgent->new; 

#See parameters for POST below __END__
my $req = (
POST 'http://www.bioinformatics.nl/tools/seqatoms/cgi-bin/blastsearch',
	Content_Type => 'form-data',
	Content => [
		mask => 0,
		db => "pdb_seqatms",
		filter => "N",
		expect => 10,
		descript => 500,
		align => 250,
		fname => [ $file ],
	]
);

my $response = $ua->request($req);
my $content = $response->content;

if (not $response->is_success or $content =~ /Software error/) { #no status header for error generated!
	warn $response->status_line, "\n";
	die "An error occured with submitting and/or processing your query.\n";
} else {
	print $content;
}


__END__
#PARAMETERS:
# fname = filename containing sequence: 
# db: pdb_seqatms | cath | disprot | pdb_seqres or a combination; default: pdb_seqatms
# expect = number of E-value threshold; default: 10
# gaps = "11/1" (gap open/extension pair)
# scoring matrix: matrix = BLOSUM45 | BLOSUM62 | BLOSUM80 | PAM30 | PAM70
# masking: mask = 0 | 1 (lowercase or "x"); default: 0 
# descript = number of description lines in BLAST report; default: 500 
# align = number of alignments; default: 250
