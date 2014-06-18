use strict;
use LWP::Simple;

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
          print MYFILE "    SPAN START\n";
          print $dates->[0];
          print "\n";
          print $dates->[1];
          print "\n";
          print $dates->[2];
          print "\n";
          print $dates->[3];
          print "\n";

          if ($dates->[1]{"class"} eq "left-box") {
            print MYFILE $p->get_text("/span");
            print MYFILE "\n";
          }
          print MYFILE "    span end\n";
        }
      }
      print MYFILE "  LINKS end\n";
    }
  print MYFILE "TD end\n";

#    my $url = $token->[1]{href} || "-";
#    my $text = $p->get_trimmed_text("/a");
#    print "$url\t$text\n";
}

close (MYFILE);