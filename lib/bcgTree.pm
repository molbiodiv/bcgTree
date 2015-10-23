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
	my $separator = $self->{'separator'};
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
			my($id,$gene,$score) = (split(/\s/))[0,3,5];
			$gene_id_map{$gene}->{$p} = {id => $id, score => $score} unless(exists $gene_id_map{$gene}->{$p} and $gene_id_map{$gene}->{$p}->{score}>$score);
		}
		close IN or $L->logdie("Error closing $out/$p.hmmsearch.tsv. $!");
	}
	$self->{genes} = [keys %gene_id_map];
	foreach my $g (keys %gene_id_map){
		open(OUT, ">$out/$g.ids") or $L->logdie("Error opening $out/$g.ids. $!");
		my $count = 0;
		foreach my $id (map {$gene_id_map{$g}{$_}{id}} keys %{$gene_id_map{$g}}){
			print OUT "$id\n";
			$count++;
		}
		$L->info("Wrote $count ids for gene $g");
		close OUT or $L->logdie("Error closing $out/$g.ids. $!");
	}
	$L->info("Finished collection of best hmmsearch hits.");
}

sub get_sequences_of_best_hmm_hits{
	my $self = shift;
	my @genes = @{$self->{genes}};
	my $out = $self->{'outdir'};
	my $separator = $self->{'separator'};
	$L->info("Collecting sequences of best hits from hmmsearch for each gene.");
	foreach my $gene (@genes){
		my $cmd = "$FindBin::RealBin/../SeqFilter/bin/SeqFilter --ids-rename='s/$separator/ /' --desc-replace --line-width 0 $out/all.concat.fa --ids $out/$gene.ids --out $out/$gene.fa 2>&1";
		$L->info($cmd);
		my $result = qx($cmd);
		$L->debug($result);
	}
	$L->info("Finished collection of sequences of best hits from hmmsearch.");
}

sub run_muscle_and_gblocks{
	my $self = shift;
	my @genes = @{$self->{genes}};
	my $out = $self->{'outdir'};
	$L->info("Running muscle and Gblocks on gene sets.");
	foreach my $gene (@genes){
		# muscle
		my $cmd = $self->{'muscle-bin'}." -in $out/$gene.fa -out $out/$gene.aln";
		$L->info($cmd);
		my $result = qx($cmd);
		$L->debug($result);
		# Gblocks
		$cmd = $self->{'gblocks-bin'}." $out/$gene.aln -t p -b1 50 -b2 85 -b4 4";
		$L->info($cmd);
		$result = qx($cmd);
		$L->debug($result);
		# Removel of unnecessary spaces
		$cmd = "perl -i -pe 's/ //g unless(/^>/)' $out/$gene.aln-gb";
		$L->info($cmd);
		$result = qx($cmd);
	}
	$L->info("Finished muscle and Gblocks.");
}

=head2 complete_and_concat_alignments

Read in all the gblock files for all the genes (alpha-numeric order). Add missing proteomes as gap-only sequences.
Write completed sequence files with proteomes in alpha-numeric order.
Additionally write full_alignment.concat.fa containing a concatenation of all gene blocks (in alpha-numeric order).

=cut

sub complete_and_concat_alignments{
	my $self = shift;
	my @genes = @{$self->{genes}};
	my %proteome = %{$self->{proteome}};
	my $out = $self->{'outdir'};
	my %fullseq = ();
	$L->info("Completing and concatenating alignments.");
	foreach my $gene (sort @genes){
		unless(-f "$out/$gene.aln-gb"){
			$L->warn("No Gblocks file for gene $gene - most likely only found in one proteome. Skipping...");
			next;
		}
		my %seq = ();
		my $length = 0;
		my $seqIn = Bio::SeqIO->new(-file => "$out/$gene.aln-gb", -format => "fasta");
		while(my $seq = $seqIn->next_seq){
			$seq{$seq->id} = $seq->seq;
			$length = $seq->length;
		}
		open(OUT, ">$out/$gene.aln-gb.comp") or $L->logdie("Error opening $out/$gene.aln-gb.comp. $!");
		foreach my $p (sort keys %proteome){
			my $s = "-" x $length;
			$s = $seq{$p} if(exists $seq{$p});
			print OUT ">$p\n";
			print OUT "$s\n";
			$fullseq{$p} = "" unless(exists $fullseq{$p});
			$fullseq{$p} .= $s;
		}
		close OUT or $L->logdie("Error closing $out/$gene.aln-gb.comp. $!");
	}
	open(OUT, ">$out/full_alignment.concat.fa") or $L->logdie("Error opening $out/full_alignment.concat.fa. $!");
	foreach my $p (sort keys %proteome){
		print OUT ">$p\n";
		print OUT "$fullseq{$p}\n";
	}
	close OUT or $L->logdie("Error closing $out/full_alignment.concat.fa. $!");
	$L->info("Completing and concatenating alignments finished.");
}

1;

=head1 AUTHORS

=over

=item * Markus Ankenbrand, markus.ankenbrand@uni-wuerzburg.de

=item * Alexander Keller, a.keller@biozentrum.uni-wuerzburg.de

=back

