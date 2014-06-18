use strict;
use LWP::Simple;
use Encode;
use utf8;

my $html = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

use HTML::TokeParser;
open (MYFILE, '>data.txt');
my $p = HTML::TokeParser->new( \$html );

while (my $token = $p->get_tag("dt")) {
    print MYFILE "DT START\n";

    while (my $links = $p->get_tag("a")) {
      print MYFILE "  LINKS START\n";
      if ($links->[1]{class} eq "topictitle") {
        my $topic_name = $p->get_trimmed_text("/a");
        my $topic_link = $links->[1]{href};

        while (my $dates = $p->get_tag("span")) {
          if ($dates->[1]{"class"} eq "left-box") {
		    my $span_text = $p->get_trimmed_text("/span");
            if (index($span_text, "Вчера") != -1 || index($span_text, "Сегодня") != -1) {
              print MYFILE $topic_name || ' - ' || $topic_link;
              print MYFILE "\n";
            }
          }
          print MYFILE "    span end\n";
        }
      }
     print MYFILE "  LINKS end\n";
    }
  print MYFILE "TD end\n";
}

close (MYFILE);