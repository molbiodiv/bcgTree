use strict;
use warnings;

use Test::More tests => 2;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "07_tmp";

my %options = (exit => 0);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'Acholeplasma=t/data/NC_005966.faa',
                   '--outdir', $tmpdir
                  ];

script_runs($script_args, \%options, "Test if script runs with existent fasta file as parameter");
file_contents_like("$tmpdir/Acholeplasma.hmmsearch.tsv", qr/Acholeplasma_gi\|50085067\|ref\|YP_046577.1\|\s+-\s+PGK\s+PF00162\.14/, "Output file contains the expected output (hmmsearch)");
remove_tree($tmpdir);