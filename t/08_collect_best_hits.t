use strict;
use warnings;

use Test::More tests => 7;
use Test::Script;
use Test::File::Contents;
use File::Path qw(remove_tree);

my $tmpdir = "08_tmp";

# dies because too few species for raxml
my %options = (exit => 1);

my $script_args = ['bin/bcgTree.pl',
                   '--proteome', 'Acinetobacter=t/data/NC_005966.faa',
                   '--proteome', 'Escherichia=t/data/NC_008253.faa',
                   '--outdir', $tmpdir
                  ];

script_runs($script_args, \%options, "Test if script collects best hmmsearch hits");
file_contents_like("$tmpdir/TIGR02386.ids", qr/Acinetobacter_-_gi\|50083580\|ref\|YP_045090.1\|/, "Output file contains the expected best hit from proteome 1");
file_contents_like("$tmpdir/TIGR02386.ids", qr/Escherichia_-_gi\|110644323\|ref\|YP_672053.1\|/, "Output file contains the expected best hit from proteome 2");
file_contents_like("$tmpdir/TIGR00436.ids", qr/Acinetobacter_-_gi\|50085654\|ref\|YP_047164.1\|/, "Output file contains the best hit in case of multiple reported hits");
file_contents_unlike("$tmpdir/TIGR00436.ids", qr/Acinetobacter_-_gi\|161349970\|ref\|YP_045311.2\|/, "Output file does not contains the second best hit");
file_contents_like("$tmpdir/TIGR02027.fa", qr/MTRTANEFLTPQAIKVEAVSGTSAKVILEPLERGFGHTLGNALRRILLSSLPGAAVVEVEIEGVEHEYSTLEGLQQDIVELLLNLKGLSIKLFDQNEAYLTLEKQGPGDITAADLRLPHNVEVVNPEHLIGTLSASGSIKMRLKVSQGRGYETSDSRFPEGETRPVGRLQLDASYSPIKRVSYTVENARVEQRTDLDKLVIDLETNGTVDPEEAIRKAATILQQQIAIFVDLQKDQAPVAQEPREEVDPILLRPVDDLELTVRSANCLKAENIYYIGDLVQRTEVELLKTPNLGKKSLTEIKDVLASKGLQLGMRLENWPPASLRMDDRFAYRSR/, "Output file contains the expected sequence of best hit from proteome 1");
file_contents_like("$tmpdir/TIGR02027.fa", qr/MQGSVTEFLKPRLVDIEQVSSTHAKVTLEPLERGFGHTLGNALRRILLSSMPGCAVTEVEIDGVLHEYSTKEGVQEDILEILLNLKGLAVRVQGKDEVILTLNKSGIGPVTAADITHDGDVEIVKPQHVICHLTDENASISMRIKVQRGRGYVPASTRIHSEEDERPIGRLLVDACYSPVERIAYNVEAARVEQRTDLDKLVIEMETNGTIDPEEAIRRAATILAEQLEAFVDLRDVRQPEVKEEKPEFDPILLRPVDDLELTVRSANCLKAEAIHYIGDLVQRTEVELLKTPNLGKKSLTEIKDVLASRGLSLGMRLENWPPASIADE/, "Output file contains the expected sequence of best hit from proteome 2");
remove_tree($tmpdir);