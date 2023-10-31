#!/usr/bin/perl 

use warnings;
#use strict;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

my $file = $ARGV[0] or die "Provide the filename of your sequence file as argument:\n perl $0 <filename>\n";
my $Quark_user = $ARGV[1] or die "Provide the username for QUARK\n";
my $Quark_password = $ARGV[2] or die "Provide the password for QUARK\n";
my $ua = LWP::UserAgent->new; 

#See parameters for POST below __END__
my $req = (
POST 'https://zhanglab.ccmb.med.umich.edu/QUARK/bin/QUARKa.cgi',
	Content_Type => 'form-data',
	Content => [
		"seq_file" => [ $file ],
		"REPLY-E-MAIL" => "$Quark_user\@uiowa.edu",
		"password" => $Quark_password,
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
# seq_file = Sequence (in FASTA format) less than 200 AA
# REPLY-E-MAIL = Email: Mandatory, where results will be sent to; only academic email accounts are acceptable
# password = Passrord: Mandatory; register for an account at https://zhanglab.ccmb.med.umich.edu/QUARK/registration/

