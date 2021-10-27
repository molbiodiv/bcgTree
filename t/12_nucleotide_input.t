use strict;
use warnings;

use Test::More tests => 2;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "12_tmp";

my %options = (exit => 0);

my $script_args = ['bin/bcgTree.pl',
                   '--genome', 'Acinetobacter=t/data/NC_005966.fna',
                   '--proteome', 'Bacillus=t/data/NC_014639.faa',
                   '--genome', 'Escherichia=t/data/NC_008253.fna',
#                   '--genome', 'Filifactor=t/data/NC_016630.faa',
                   '--genome', 'Acholeplasma=t/data/NC_022549.fna',
                   '--outdir', $tmpdir,
                   '--bootstrap', 10,
                   '--raxml-aa-substitution-model', 'WAG'
                  ];

script_runs($script_args, \%options, "Test if script creates a tree given mixed peptide and nucleotide input");
ok(-f "$tmpdir/RAxML_bestTree.final", "Final raxml tree file exists");
remove_tree($tmpdir);