use strict;
use LWP::Simple;
use Encode;
use utf8;

my $html = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

use HTML::TokeParser;
my $key;
my $value;
my %already_sended;
my %new_topics;

open (MYFILE, '+<topics.txt');

while (<MYFILE>) {
	($key, $value) = split("\t");
	$already_sended{$key} = $value;
 }

 # while (($key, $value) = each(%already_sended)) {
	 # print "$key is $value\n";
# } 


my $p = HTML::TokeParser->new( \$html );

my $topic_link;
my $topic_name;
my $check_link;

while (my $token = $p->get_tag("dt", "a", "span")) {
	if ($token->[0] eq "dt") {
		$topic_link = "";
		$topic_name = "";
		$check_link = 0;
	} elsif ($token->[0] eq "a" && $token->[1]{class} eq "topictitle") {
		($topic_link) = ($token->[1]{href} =~ /(.*)&sid.*/);
#		       $topic_link = $token->[1]{href};
#			   $topic_link =~ s/&sid.*//g;
		if (not exists $already_sended{$topic_link}) {
			$topic_name = $p->get_trimmed_text("/a");
			$check_link = 1;
		}
	} elsif ($check_link && $token->[0] eq "span" && $token->[1]{class} eq "left-box") {
		my $span_text = $p->get_trimmed_text("/span");
		if (
				index($span_text, "Сегодня") != -1
			 || index($span_text, "минут") != -1
			 || index($span_text, "секунд") != -1
			 || index($span_text, "Вчера") != -1 
		) 
		{
			print MYFILE "$topic_link\t$topic_name\n";
			$new_topics{$topic_link} = $topic_name;
			$topic_link = "";
			$topic_name = "";
		}

	}
}

# while (($key, $value) = each(%new_topics)) {
	# print "$key is $value\n";
# }


close (MYFILE);