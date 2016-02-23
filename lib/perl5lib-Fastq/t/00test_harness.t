use strict;
use warnings;
use Test::Harness;
use FindBin qw($RealBin);
use Data::Dumper;
use Cwd;

my $cwd = cwd;
chdir("$RealBin/");
my @tests = grep {!/^00test_harness.t/} glob("*.t");
runtests(@tests);
chdir($cwd);