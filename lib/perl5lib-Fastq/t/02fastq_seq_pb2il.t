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
	use_ok('Fastq::Seq::Pb2Il'); 
}

my $Class = 'Fastq::Seq';

#--------------------------------------------------------------------------#


#--------------------------------------------------------------------------#
=head2 create Fastq::Seq object for testing

=cut

my $fq_seq = new_ok($Class, ['@bla'."\nACCGTA\n+\nIIHHGG"]);
is($fq_seq->seq_head(), '@bla', "Correct Sequence Header");
is($fq_seq->seq(), "ACCGTA", "Correct Sequence");
is($fq_seq->qual_head(), "+", "Correct Quality Header");
is($fq_seq->qual(), "IIHHGG", "Correct Quality");

#--------------------------------------------------------------------------#


#--------------------------------------------------------------------------#
=head2 test pb2il unpaired

=cut

can_ok('Fastq::Seq', ('pb2il'));
can_ok($fq_seq, ('pb2il'));

subtest 'pb2il - unpaired' => \&test_left_reads;

sub test_left_reads{
	my @reads = $fq_seq->pb2il('length'=>2,'step'=>1);
	# print Dumper(\@reads);

	my $first_left = new_ok($Class, ['@bla.1 SUBSTR:0,2'."\nAC\n+\nII"]);
	isa_ok($reads[0][0], $Class, "first left read");
	cmp_deeply($reads[0][0], $first_left, 'First left read deeply');
	
	my $second_left = new_ok($Class, ['@bla.2 SUBSTR:1,2'."\nCC\n+\nIH"]);
	isa_ok($reads[0][1], $Class, "Second left read");
	cmp_deeply($reads[0][1], $second_left, 'Second left read deeply');
	
	my $read = $Class->new('@bla.3 SUBSTR:2,2'."\nCG\n+\nHH");
	isa_ok($reads[0][2], $Class, "Third left read");
	cmp_deeply($reads[0][2], $read, 'Third left read deeply');
	
	$read = $Class->new('@bla.4 SUBSTR:3,2'."\nGT\n+\nHG");
	isa_ok($reads[0][3], $Class, "Fourth left read");
	cmp_deeply($reads[0][3], $read, 'Fourth left read deeply');
	
	$read = $Class->new('@bla.5 SUBSTR:4,2'."\nTA\n+\nGG");
	isa_ok($reads[0][4], $Class, "Fifth left read");
	cmp_deeply($reads[0][4], $read, 'Fifth left read deeply');

	is($reads[1], undef, 'no pairs in unpaired mode');
};

#--------------------------------------------------------------------------#


#--------------------------------------------------------------------------#
=head2 test pb2il paired

=cut

subtest 'pb2il - paired' => sub{
my @reads_paired = $fq_seq->pb2il('length'=>2,'step'=>1,'insert'=>3,'paired'=>1);
# print Dumper(\@reads);

	my $first_left_pair = new_ok($Class, ['@bla.1 SUBSTR:0,2'."\nAC\n+\nII"], 'First left pair');
	isa_ok($reads_paired[0][0], $Class, "first left pair");
	cmp_deeply($reads_paired[0][0], $first_left_pair, 'First left pair deeply');

	my $first_right_pair = new_ok($Class, ['@bla.1 SUBSTR:3,2'."\nGG\n+\nHI"]);
	isa_ok($reads_paired[1][0], $Class, "First right pair");
	cmp_deeply($reads_paired[1][0], $first_right_pair, 'First right pair deeply');
	
	my $right_pair = new_ok($Class, ['@bla.2 SUBSTR:2,2'."\nCG\n+\nHH"]);
	isa_ok($reads_paired[1][1], $Class, "Second right pair");
	cmp_deeply($reads_paired[1][1], $right_pair, 'Second right pair deeply');
};


#--------------------------------------------------------------------------#

done_testing();

__END__


