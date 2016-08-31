use strict;
use warnings;

use Test::More tests => 3;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "10_tmp";

# dies because no gene is found in two proteomes
my %options = (exit => 1);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'Acinetobacter=t/data/Acinetobacter_PF002xx.fa',
                   '--proteome', 'Escherichia=t/data/Escherichia_PF002xx.fa',
                   '--proteome', 'Filifactor=t/data/Filifactor_PF002xx.fa',
                   '--outdir', $tmpdir,
                   '--bootstrap', 10
                  ];

script_runs($script_args, \%options, "Test if script runs muscle correctly");
files_eq("$tmpdir/TIGR01030.aln-gb.comp", "t/expected/TIGR01030.aln-gb.comp", "Output file contains the expected alignmed sequences with gaps added for the missing sequence");
files_eq("$tmpdir/full_alignment.concat.fa", "t/expected/full_alignment.concat.fa", "Output file contains the concatenated sequence blocks");
remove_tree($tmpdir);