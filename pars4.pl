package main;

use HTML::Parser;
use LWP::Simple;

my $p = HTML::Parser->new(api_version => 3,
     start_h => [\&a_start_handler, "self,tagname,attr"],
     report_tags => [qw(a img)],
    );

open (MYFILE, '>>data.txt');
$p->parse(get("http://forum.awd.ru/viewforum.php?f=60")) || die $!;
close (MYFILE);

#while (($key, $val) = each(%topics))
#{
#	print "$key is $val\n";
#}

sub a_start_handler
{
    my($self, $tag, $attr) = @_;
    return unless $tag eq "a";
    return unless $attr->{class} eq 'topictitle';
    $new_topic = $attr->{href};
    print "A link\n";

    $self->handler(text  => [], '@{dtext}' );
    $self->handler(end   => \&a_end_handler, "self,tagname");

}

sub a_end_handler
{
    my($self, $tag) = @_;
    my $text = join("", @{$self->handler("text")});
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    $text =~ s/\s+/ /g;
    $topics{$new_topic} = $text;
    print "T text\n";

#    $self->handler("text", undef);
#    $self->handler("start", \&a_start_handler);
#    $self->handler("end", undef);
    $self->handler(start  => \&span_start_handler, 'self,tagname,attr' );

}

sub span_start_handler {
    my($self, $tag, $attr) = @_;
    return unless $tag eq "span";
    return unless $attr->{class} eq 'left-box';

    print "Span start  ";
    $self->handler(end   => \&a_end_handler, "self,tagname");

  }

sub span_end_handler {
    my($self, $tag, $attr) = @_;
    return unless $tag eq "span";

    print "  Span - end\n";
    $self->handler("text", undef);
    $self->handler("start", \&a_start_handler);
    $self->handler("end", undef);

  }


