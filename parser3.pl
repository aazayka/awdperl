use strict;
use LWP::Simple;
use Encode;
use utf8;

my $html = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

use HTML::TokeParser;
open (MYFILE, '>data.txt');
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
		$topic_link = $token->[1]{href};
		$topic_name = $p->get_trimmed_text("/a");
		$check_link = 1;
	} elsif ($check_link && $token->[0] eq "span" && $token->[1]{class} eq "left-box") {
		my $span_text = $p->get_trimmed_text("/span");
		if (
				index($span_text, "Сегодня") != -1
			 || index($span_text, "минут") != -1
			 || index($span_text, "секунд") != -1
			 || index($span_text, "Вчера") != -1 
		) 
		{
			print MYFILE "$span_text: $topic_name  - $topic_link\n";
			$topic_link = "";
			$topic_name = "";
		}

	}
}

close (MYFILE);