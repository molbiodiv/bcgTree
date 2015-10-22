use strict;
use warnings;

use Test::More tests => 4;
use Test::Script;

my $script_args = ['bin/bcgTree.pl', '-h'];
my %options = (exit => 1);

script_runs($script_args, \%options, "Test if script runs with -h as argument");
script_stdout_like(qr/Usage/, "Result of run with -h as argument returned Usage information");

$script_args = ['bin/bcgTree.pl', '--help'];

script_runs($script_args, \%options, "Test if script runs with --help as argument");
script_stdout_like(qr/Usage/, "Result of run with --help as argument returned Usage information");