package bcgTree;

use 5.010000;
use strict;
use warnings;
use Log::Log4perl qw(:no_extra_logdie_message);
use File::Path qw(make_path);
use Bio::SeqIO;

our $VERSION = '0.1';

# init a root logger in exec mode
Log::Log4perl->init(
	\q(
                log4perl.rootLogger                     = DEBUG, Screen
                log4perl.appender.Screen                = Log::Log4perl::Appender::Screen
                log4perl.appender.Screen.stderr         = 1
                log4perl.appender.Screen.layout         = PatternLayout
                log4perl.appender.Screen.layout.ConversionPattern = [%d{MM-dd HH:mm:ss}] [%C] %m%n
        )
);

my $L = Log::Log4perl::get_logger();

sub new {
      my $class = shift;
      my $object = shift;
      return bless $object, $class;
}

sub check_existence_of_fasta_files{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	foreach(keys %proteome){
	    $L->logdie("File not found: ".$proteome{$_}) unless(-f $proteome{$_});
	}
}

sub create_outdir_if_not_exists{
	my $self = shift;
	my $outdir = $self->{outdir};
	make_path($outdir, {error => \my $err});
	if (@$err)
	{
	    for my $diag (@$err) {
			my ($file, $message) = %$diag;
			if ($file eq '') {
				$L->logdie("Creating folder failed with general error: $message");
			}
			else {
				$L->logdie("Creating folder failed for folder '$file': $message");
			}
	    }
	}
}

sub rename_fasta_headers{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	my $separator = "_";
	foreach my $p (keys %proteome){
		my $seqIn = Bio::SeqIO->new(-file => "$proteome{$p}", -format => "fasta");
		my $seqOut = Bio::SeqIO->new(-file => ">".$self->{outdir}."/".$p.".fa", -format => "fasta");
		while(my $seq = $seqIn->next_seq){
			$seq->id($p.$separator.$seq->id());
			$seqOut->write_seq($seq);
		}
	}
}

1;

=head1 AUTHORS

=over

=item * Markus Ankenbrand, markus.ankenbrand@uni-wuerzburg.de

=item * Alexander Keller, a.keller@biozentrum.uni-wuerzburg.de

=back

