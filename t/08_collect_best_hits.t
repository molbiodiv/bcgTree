use strict;
use warnings;

use Test::More tests => 3;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "08_tmp";

my %options = (exit => 0);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'Acinetobacter=t/data/NC_005966.faa',
                   '--proteome', 'Escherichia=t/data/NC_008253.faa',
                   '--outdir', $tmpdir
                  ];

script_runs($script_args, \%options, "Test if script collects best hmmsearch hits");
file_contents_like("$tmpdir/TIGR02386.ids", qr/Acinetobacter_gi\|50083580\|ref\|YP_045090.1\|/, "Output file contains the expected best hit from proteome 1");
file_contents_like("$tmpdir/TIGR02386.ids", qr/Escherichia_gi\|110644323\|ref\|YP_672053.1\|/, "Output file contains the expected best hit from proteome 2");
remove_tree($tmpdir);