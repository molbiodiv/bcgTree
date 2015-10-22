use strict;
use warnings;

use Test::More;
use FindBin;

my $script = $FindBin::RealBin."/../bin/bcgTree.pl";
ok(-f $script, "bcgTree.pl exists");

# Test with non existent file path
my $result = qx($script --proteome bla=non_existent_file.fasta 2>&1);
ok($?, "Script finishes with error code if fasta file does not exist.");
ok($result =~ /File not found/, "Error message contains text 'File not found': $result");

done_testing();
