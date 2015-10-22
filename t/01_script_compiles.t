use strict;
use warnings;

use Test::More tests=>3;
use Test::Script;
use FindBin;

# Test for use of cpgTree module and existence of script
BEGIN { use_ok('bcgTree') };
my $script = "bin/bcgTree.pl";
ok(-f $script, "bcgTree.pl exists");
script_compiles($script, "Test if script compiles");
