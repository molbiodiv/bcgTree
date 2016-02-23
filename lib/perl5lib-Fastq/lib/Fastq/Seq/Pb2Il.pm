package Fastq::Seq::Pb2Il;

use lib '../';
use Data::Dumper;
use strict;
use warnings;

=head1 NAME 

Pb2Il.pm

=head1 DESCRIPTION

This module expands the functionality of the Fastq::Seq class.
Large fastq sequences can be shredded into smaller ones (paired or unpaired).
It is called Pb2Il as abbreviation for "PacBio to Illumina".
Of course any larger sequence can be used and the output are no real Illumina reads.

=head1 USAGE

# When this module is loaded every Fastq::Seq object has the additional method pb2il()

use Fastq::Seq::Pb2Il

my $seq = Fastq::Seq->new()
my %options = ('length' => 100, 'insert' => 180, 'step' => 150, 'paired' => 1, 'masked' => 0);

my @shreds = $seq->pb2il(%options)
my @leftreads = @{$shreds[0]}
my @rightreads = @{$shreds[1]}


=head1 OPTIONS of pb2il

=over 25

=item 'length' => INT

Gives the desired length of each output read in bp. (Default: 100bp)

=item 'insert' => INT

Gives the desired insert size in bp this is the total length of the insert:
2*length + 1*gap, eg length=100 and insert=150 means, that the reads of a pair overlap by 50bp.
Only important if paired=1 otherwise it is always considered, that insert=length.
(Default: 150)

=item 'paired' => BOOLEAN

Wheter or not the output should be single reads or pairs.
If paired=1 there are two array references returned with leftpairs as first element and rightpairs as second.
Otherwise there is only one arrayreference returned for the unpaired reads.
The reads orientation is inward (-->  <--), insert size is set with the 'insert' option.
(Default: 0)

=item 'step' => INT

Gives the distance between the start points of two adjacent leftpairs on the original sequence. (Default: 150bp)

=item 'masked' => BOOLEAN

Wheter or not lowercase letters should be treated as masking.
If so, all reads/pairs that contain lowercase letters are discarded.
The method still goes over the read in its fixed raster,
it is not searching for possible pairs without lowercase letters, 
it just discards the reads if they contain some. 
(Default: 0)

=item 'opp-out' => BOOLEAN

Wheter the readpairs should be oriented outwards (Default is inwards).
Outwards means both reads of a pair get reverse complemented.
This option is ignored if option 'paired' is not set.
(Default: 0)

=cut

sub Fastq::Seq::pb2il {
	my $self    = shift->new;
	my %options = (
		'length' => 100,
		'insert' => 180,
		'paired' => 0,
		'step'   => 150,
		'masked' => 0,
		'opp-out' => 0,
		@_
	);
	$options{'insert'} = $options{'length'} unless ( $options{'paired'} );
	my $comp;
	if ( $options{'paired'} ) {
		$comp = $self->new;
		$comp->reverse_complement();
	}
	my $seq = $self->seq();
	
	my %illegal_startpoints = ();
	if ( $options{'masked'} ) {
		while($seq =~ /([a-z])/g ){
			my $position = pos($seq);
			for(my $i=($position-$options{'insert'}); $i<($position-$options{'insert'}+$options{'length'}); $i++){
				$illegal_startpoints{$i} = 1;
			}
			for(my $i=$position-$options{'length'}; $i<$position; $i++){
				$illegal_startpoints{$i} = 1;
			}
		}
	}
	# Create ranges
	my @ranges    = ();
	my @ranges_rc = ();
	for (my $start = 0 ; $start <= ( length($seq) - $options{'insert'} ) ; $start += $options{'step'}){
		next if($illegal_startpoints{$start});
		push( @ranges, [ $start, $options{'length'} ] );
		if ( $options{'paired'} ) {
			push(@ranges_rc,[length($seq) - $start - $options{'insert'},$options{'length'}]);
		}
	}
	my $leftpairs  = undef;
	$leftpairs = [ $self->substr_seq(@ranges) ] if(@ranges);
	my $rightpairs = undef;
	if($options{'paired'} and @ranges_rc){
		$rightpairs = [ $comp->substr_seq(@ranges_rc) ];
	}
	if($options{'paired'} && $options{'opp-out'}){
		$_->reverse_complement() foreach(@{$rightpairs});
		$_->reverse_complement() foreach(@{$leftpairs});
	}
	return $options{'paired'} ? ( $leftpairs, $rightpairs ) : ( $leftpairs );
}

1;
