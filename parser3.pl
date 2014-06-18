use strict;
use LWP::Simple;

my $html = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

 use HTML::TokeParser::Simple;
 my $p = HTML::TokeParser::Simple->new( $html );

 while ( my $token = $p->get_token ) {
     # This prints all text in an HTML doc (i.e., it strips the HTML)
     next unless $token->is_text;
     print $token->as_is;
 }