use strict;
use LWP::Simple;
use Encode;
use utf8;
use HTML::TokeParser;
use MIME::Lite;
use Net::SMTP::SSL;

my $smtp_server = 'smtp.mail.ru';
my $from = ''; -- кто шлет
my $to = ''; -- кому шлют
my @recipients = (''); -- массив получателей
my $pass = ''; -- пароль


my $html = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

my $key;
my $value;
my %already_sended;
my %new_topics;

use FindBin;
open (MYFILE, '<', $FindBin::Bin.'/topics.txt');

while (<MYFILE>) {
	($key, $value) = split("\t");
	$already_sended{$key} = $value;
 }

close(MYFILE);

open (MYFILE, '>>', $FindBin::Bin.'/topics.txt');

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
		if (not exists $already_sended{$topic_link}) {
			$topic_name = $p->get_trimmed_text("/a");
			$check_link = 1;
		}
	} elsif ($check_link && $token->[0] eq "span" && $token->[1]{class} eq "left-box") {
		my $span_text = decode("utf8", $p->get_trimmed_text("/span"));
		if (1) 
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
	  $message .= "<a href='http://forum.awd.ru/$key'>$value</a><br/><br/>\n";
	  #$message .= "<a href='http://forum.awd.ru/$key'>fuck</a><br/><br/>\n";
	}

#	print $message;
#	my $msg = MIME::Lite->new(
#					From     => $from ,
#					To       => $to ,
#					Subject  => 'New topics from awd.ru',
					# Type    => 'text/html; charset=UTF-8',
					# Data    => $message);

	my $smtp; 
	$smtp = Net::SMTP::SSL->new($smtp_server, Port=>465) or die "Can't connect";
	$smtp->auth($from, $pass) or die "Can't authenticate:".$smtp->message();
	$smtp->mail($from) or die "Error:".$smtp->message();

	$smtp->recipient(@recipients);
	$smtp->to($to) or die "Error:".$smtp->message();
	$smtp->data() or die "Error:".$smtp->message();

	$smtp->datasend("To: $to\n");
	$smtp->datasend("From: $from\n");
	$smtp->datasend("Content-Type: text/html; charset=UTF-8\n");
	$smtp->datasend("Subject: New topics from awd.ru");
	# line break to separate headers from message body
	$smtp->datasend("\n");
	$smtp->datasend($message);
	$smtp->datasend("\n");
	$smtp->dataend() or die "Error:".$smtp->message();
	$smtp->quit() or die "Error:".$smtp->message();
	
}
