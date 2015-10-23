package bcgTree;

use 5.010000;
use strict;
use warnings;
use Log::Log4perl qw(:no_extra_logdie_message);
use File::Path qw(make_path);
use FindBin;
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

=head2 rename_fasta_headers

This function creates a temporary fasta file for each proteome with name added to the beginning of each id.
Additionally a all.concat.fa file is created that contains a concatenation of all proteome fasta files (with renamed headers).

=cut

sub rename_fasta_headers{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	my $separator = "_";
	my $seqOutAll = Bio::SeqIO->new(-file => ">".$self->{outdir}."/all.concat.fa", -format => "fasta");
	foreach my $p (keys %proteome){
		my $seqIn = Bio::SeqIO->new(-file => "$proteome{$p}", -format => "fasta");
		my $seqOut = Bio::SeqIO->new(-file => ">".$self->{outdir}."/".$p.".fa", -format => "fasta");
		while(my $seq = $seqIn->next_seq){
			$seq->id($p.$separator.$seq->id());
			$seqOut->write_seq($seq);
			$seqOutAll->write_seq($seq);
		}
	}
}

sub run_hmmsearch{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	my $out = $self->{'outdir'};
	$L->info("Running hmmsearch on proteomes.");
	foreach my $p (keys %proteome){
		my $cmd = $self->{'hmmsearch-bin'}." --cut_tc --notextw --tblout $out/$p.hmmsearch.tsv $FindBin::RealBin/../data/essential.hmm $out/$p.fa";
		$L->info($cmd);
		my $result = qx($cmd);
		$L->debug($result);
	}
	$L->info("Finished hmmsearch.");
}

sub collect_best_hmm_hits{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	my $out = $self->{'outdir'};
	$L->info("Collecting best hits from hmmsearch for each gene.");
	my %gene_id_map;
	foreach my $p (keys %proteome){
		open(IN, "<$out/$p.hmmsearch.tsv") or $L->logdie("Error opening $out/$p.hmmsearch.tsv. $!");
		while(<IN>){
			next if(/^#/);
			s/ * / /g;
			my($id,$gene) = (split(/\s/))[0,3];
			push(@{$gene_id_map{$gene}}, $id);
		}
		close IN or $L->logdie("Error closing $out/$p.hmmsearch.tsv. $!");
	}
	foreach my $g (keys %gene_id_map){
		open(OUT, ">$out/$g.ids") or $L->logdie("Error opening $out/$g.ids. $!");
		foreach my $id (@{$gene_id_map{$g}}){
			print OUT "$id\n";
		}
		$L->info("Wrote ".(@{$gene_id_map{$g}}+0)." ids for gene $g");
		close OUT or $L->logdie("Error closing $out/$g.ids. $!");
	}
	$L->info("Finished collection of best hmmsearch hits.");
}

1;

=head1 AUTHORS

=over

=item * Markus Ankenbrand, markus.ankenbrand@uni-wuerzburg.de

=item * Alexander Keller, a.keller@biozentrum.uni-wuerzburg.de

=back

