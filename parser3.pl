use strict;
use LWP::Simple;
use Encode;
use utf8;
use HTML::TokeParser;
use MIME::Lite;

my $smtp_server = 'smtp.mail.ru';
my $from = '*****@mail.ru';
my $to = 'aazayka@mail.ru;bulidze@gmail.com';
my $pass = '*****';


my $html = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

my $key;
my $value;
my %already_sended;
my %new_topics;

open (MYFILE, '+<topics.txt');

while (<MYFILE>) {
	($key, $value) = split("\t");
	$already_sended{$key} = $value;
 }

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

close (MYFILE);

if (scalar(keys %new_topics) > 0) {
	my $message;
	while (($key, $value) = each(%new_topics)) {
	  $message .= "<a href='http://forum.awd.ru/$key'>$value</a></br>\n";
	}
	my $msg = MIME::Lite->new(
					From     => $from ,
					To       => $to ,
					Subject  => 'New topics from awd.ru',
					Type    => 'text/html; charset=UTF-8',
					Data    => encode("utf8", $message));

	$msg->send( 'smtp' , $smtp_server , AuthUser=> $from , AuthPass=> $pass);
# , Debug=>4	
}