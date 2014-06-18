package MyParser;
use base qw(HTML::Parser);

# This parser only looks at opening tags
sub start {
my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
if ($tagname eq 'a' && $attr->{ class } eq 'topictitle') {
  print "URL found: ", $origtext, "\n";
  $self->handler(text => sub { print shift }, "dtext");
  $self->handler(end  => sub { "" }, "tagname,self");
}
}

package main;

use strict;
use LWP::Simple;

my $html = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

my $parser = MyParser->new;
$parser->parse( $html );
__END__