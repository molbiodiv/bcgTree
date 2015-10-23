use strict;
use warnings;

use Test::More tests => 2;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "12_tmp";

my %options = (exit => 0);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'Acinetobacter=t/data/NC_005966.faa',
                   '--proteome', 'Bacillus=t/data/NC_014639.faa',
                   '--proteome', 'Escherichia=t/data/NC_008253.faa',
                   '--proteome', 'Filifactor=t/data/NC_016630.faa',
                   '--proteome', 'Acholeplasma=t/data/NC_022549.faa',
                   '--outdir', $tmpdir
                  ];

script_runs($script_args, \%options, "Test if script executes raxml");
ok(-f "$tmpdir/RAxML_bestTree.final.tre", "Final raxml tree file exists");
remove_tree($tmpdir);