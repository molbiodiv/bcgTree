use strict;
use warnings;

use Test::More tests => 2;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "06_tmp";

my %options = (exit => 0);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'bacterium1=t/data/simple.fa',
                   '--outdir', $tmpdir
                  ];

script_runs($script_args, \%options, "Test if script runs with existent fasta file as parameter");
files_eq("$tmpdir/bacterium1.fa", 't/expected/simple.renamed_headers.fa', "Output file contains the expected output (renamed headers)");
remove_tree($tmpdir);