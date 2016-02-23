#!/usr/bin/env perl

# $Id$

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use FindBin qw($RealBin);
use lib "$RealBin/../lib/";


#--------------------------------------------------------------------------#
=head2 load module

=cut

BEGIN { 
	use_ok('Fastq::Seq');
	use_ok('Fastq::Parser'); 
	use_ok('Fastq::Seq::Pb2Il'); 
}

my $Class = 'Fastq::Seq';

#--------------------------------------------------------------------------#


#--------------------------------------------------------------------------#
=head2 create Fastq::Seq object for pacbio read and pb2il array with masked option (first letter masked)

=cut

my $parser = new_ok('Fastq::Parser', ['file' => $RealBin.'/06pacbio_masked.fq']);
can_ok($parser, 'next_seq');
my $pacbio_seq = $parser->next_seq();
isa_ok($pacbio_seq, $Class);
can_ok($pacbio_seq, 'pb2il');
my @pb2il_reads = $pacbio_seq->pb2il('paired' => 1, 'length' => 50, 'insert' => 150, 'step' => 50, 'masked' => 1);

#--------------------------------------------------------------------------#


#--------------------------------------------------------------------------#
=head2 create Fastq::Parsers for desired illumina reads

=cut

my $parser_il1 = new_ok('Fastq::Parser', ['file' => $RealBin.'/06illumina_1.fq']);
my $parser_il2 = new_ok('Fastq::Parser', ['file' => $RealBin.'/06illumina_2.fq']);

subtest 'pb2il - paired length=50 inser=150 step=50 masked' => sub{
	my $i=0;
	while (my $expected_right=$parser_il2->next_seq()){
		my $expected_left = $parser_il1->next_seq();
		my $got_left = shift(@{$pb2il_reads[0]});
		my $got_right = shift(@{$pb2il_reads[1]});
		cmp_deeply($got_left, $expected_left, "left $i");
		cmp_deeply($got_right, $expected_right, "right $i");
		$i++;
	}
};

my @pb2il_unpaired = $pacbio_seq->pb2il('paired' => 0, 'length' => 50, 'insert' => 150, 'step' => 50, 'masked' => 1);
my $parser_il = new_ok('Fastq::Parser', ['file' => $RealBin.'/06illumina_1_single.fq']);
subtest 'pb2il - unpaired length=50 inser=150 step=50 masked' => sub{
	my $i=0;
	while (my $expected=$parser_il->next_seq()){
		my $got = shift(@{$pb2il_unpaired[0]});
		cmp_deeply($got, $expected, "unpaired $i");
		$i++;
	}
};

#--------------------------------------------------------------------------#



done_testing();

__END__


