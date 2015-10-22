use strict;
use warnings;

use Test::More tests => 2;
use Test::Script;

my %options = (exit => 1);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'bla=non_existent_file.fasta'
                  ];

script_runs($script_args, \%options, "Test if script runs with non existent fasta file as parameter");
script_stderr_like(qr/File not found/, "Result of run with non existent fasta file returned error message");