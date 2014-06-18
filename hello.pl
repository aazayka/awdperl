print "Hello World\n";

use strict;
use LWP::Simple;

my $page = get("http://forum.awd.ru/viewforum.php?f=60")
           or die "Could not fetch NWS CSV page.";

use HTML::Parser ();

my $p = HTML::Parser->new( api_version => 3,
                       start_h => [\&start, "tagname, attr"],
                       end_h   => [\&end,   "tagname"],
                       marked_sections => 1,
                     );
