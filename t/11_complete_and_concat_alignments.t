use strict;
use warnings;

use Test::More tests => 2;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "11_tmp";

my %options = (exit => 0);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'Acinetobacter=t/data/NC_005966.faa',
                   '--proteome', 'Escherichia=t/data/NC_008253.faa',
                   '--proteome', 'Filifactor=t/data/NC_016630.faa',
                   '--outdir', $tmpdir
                  ];

script_runs($script_args, \%options, "Test if script runs muscle correctly");
files_eq("$tmpdir/TIGR01030.aln-gb.comp", "t/expected/TIGR01030.aln-gb.comp", "Output file contains the expected alignment sequence from proteome 1");
remove_tree($tmpdir);