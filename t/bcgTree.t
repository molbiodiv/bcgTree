use strict;
use warnings;

use Test::More;
use FindBin;

my $script = $FindBin::RealBin."/../bin/bcgTree.pl";
ok(-f $script, "bcgTree.pl exists");

done_testing();
