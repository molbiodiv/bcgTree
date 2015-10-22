use strict;
use warnings;

use Test::More tests => 2;
use Test::Script;

my %options = (exit => 1);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'bacterium1=t/data/simple.fa',
                   '--outdir', '/usr/sbin/bla/bla/bla'
                  ];

script_runs($script_args, \%options, "Test if script runs with outdir with no permission");
script_stderr_like(qr/Creating folder failed/, "Result of run with illegal outdir returned error message");