#!/usr/bin/perl -w

use strict;
use warnings;
use lib('/usr/lib/perl5/5.8.8');

qx(rm concatenated.fa);
qx(rm *.aln);

my @files = qx(ls *.fa);

foreach my $file (@files){
	chomp($file);
	print ">>$file<<";
	qx(sed -i .bak \"s\/\^>\\\(\[a-zA-Z_0-9.\]\*\\\)\*\[\[\:space\:\]\]\.\*\$\/>\\1\/g\" $file );
	qx(./muscle3.8.31_i86darwin64 -in $file -out $file.aln);
	qx(./Gblocks $file.aln -t p -b1 50 -b2 85 -b4 4);
	qx(sed -i .bak \"s\/\[\[\:space\:\]\]\/\/g\" $file.aln-gb );
}

qx(mkdir 0_raw);
qx(mkdir 1_aligned);
qx(mkdir 2_gblocks);
qx(mv  *.fa 0_raw/);
qx(mv  *.bak 0_raw/);
qx(mv  *.aln 1_aligned/);
qx(mv  *.aln-gb.htm 2_gblocks/);
