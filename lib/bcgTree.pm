package bcgTree;

use 5.010000;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/../lib/Log-Log4perl-1.46/lib";
use lib "$FindBin::RealBin/../lib/perl5lib-Fasta/lib";
use Log::Log4perl qw(:no_extra_logdie_message);
use File::Path qw(make_path);
use File::Spec;
use Fasta::Parser;

our $VERSION = '1.2.1';

my $L = Log::Log4perl::get_logger();

sub new {
	my $class = shift;
	my $object = shift;
	bless $object, $class;
	$object->create_outdir_if_not_exists();
	# init a root logger in exec mode
	Log::Log4perl->init(
	\q(
                log4perl.rootLogger                     = DEBUG, Screen, FileApp
				log4perl.appender.FileApp				= Log::Log4perl::Appender::File
				log4perl.appender.FileApp.filename		= sub{ logfile() }
				log4perl.appender.FileApp.layout		= PatternLayout
				log4perl.appender.FileApp.layout.ConversionPattern = [%d{MM-dd HH:mm:ss}] [%C] %m%n
                log4perl.appender.Screen                = Log::Log4perl::Appender::Screen
                log4perl.appender.Screen.stderr         = 1
                log4perl.appender.Screen.layout         = PatternLayout
                log4perl.appender.Screen.layout.ConversionPattern = [%d{MM-dd HH:mm:ss}] [%C] %m%n
        )
	);
	return $object;
}

sub check_existence_of_fasta_files{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	foreach(keys %proteome){
	    $L->logdie("File not found: ".$proteome{$_}) unless(-f $proteome{$_});
	}
	my %genome = %{$self->{genome}};
	foreach(keys %genome){
	    $L->logdie("File not found: ".$genome{$_}) unless(-f $genome{$_});
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
			# Just die instead of logdie here as the logger is not initialized when first called.
			# Set exit code to 1 explicitly - otherwise not predictable (or testable)
			$! = 1;
			if ($file eq '') {
				die("Creating folder failed with general error: $message");
			}
			else {
				die("Creating folder failed for folder '$file': $message");
			}
	    }
	}
}

=head2 rename_fasta_headers

This function creates a temporary fasta file for each proteome with an internal proteome_id added to the beginning of each id.
Usage of ids is necessary due to a limitation of Gblocks (only 72 characters allowed in header line).
Additionally a all.concat.fa file is created that contains a concatenation of all proteome fasta files (with renamed headers).
Also write a file proteome_id_map containing the mapping from proteome to id.

=cut

sub rename_fasta_headers{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	my $separator = $self->{'separator'};
	$self->{proteome_map} = {};
	my $out = $self->{outdir};
	my $proteome_id = 0;
	$L->info("Copying fasta files - adjusting headers...");
	my $seqOutAll = Fasta::Parser->new(file => "$out/all.concat.fa", mode => ">");
	foreach my $p (sort keys %proteome){
		$self->{proteome_map}{$p} = ++$proteome_id;
		my $seqIn = Fasta::Parser->new(file => "$proteome{$p}", mode => "<");
		my $seqOut = Fasta::Parser->new(file => "$out/$p.fa", mode => ">");
		while(my $seq = $seqIn->next_seq){
                    if(length($seq->seq)==0){
                        $L->warn("Empty seq: ".$proteome_id.$separator.$seq->id().". Skipping seq...")
                    } else {
			$seq->id($proteome_id.$separator.$seq->id());
			$seqOut->append_seq($seq);
			$seqOutAll->append_seq($seq);
                    }
		}
	}
	$L->info("All fasta files copied, headers adjusted.");
	$L->info("Starting: Writing of proteome_id map.");
	open(OUT, ">$out/proteome_id_map") or $L->logdie("Error opening $out/proteome_id_map. $!");
	print OUT "$_\t".$self->{proteome_map}{$_}."\n" foreach(keys %{$self->{proteome_map}});
	close OUT or $L->logdie("Error closing $out/proteome_id_map. $!");
	$L->info("Finished: Writing of proteome_id map.");
}

=head2 translate_genomes_to_proteomes

This function calls prodigal on every genome to translate it into proteome (adding the file to the proteome list afterwards)

=cut

sub translate_genomes_to_proteomes{
	my $self = shift;
	my %genome = %{$self->{genome}};
	my $out = $self->{outdir};
	$L->info("Translating genome fasta files ...");
	foreach my $g (sort keys %genome){
		my $cmd = $self->{'prodigal-bin'}." -i ".$genome{$g}." -o $out/$g.prodigal.genes -a $out/$g.prodigal.faa";
		$self->run_command($cmd, "translating $g");
		$self->{proteome}{$g} = "$out/$g.prodigal.faa"
	}
	$L->info("All genome fasta files translated.");
}

sub run_hmmsearch{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	my $out = $self->{'outdir'};
	$L->info("Running hmmsearch on proteomes.");
	foreach my $p (keys %proteome){
		my $cmd = $self->{'hmmsearch-bin'}." --cut_tc --notextw --tblout $out/$p.hmmsearch.tsv ".$self->{'hmmfile'}." $out/$p.fa";
		$self->run_command($cmd, "hmmsearch in $p");
	}
	$L->info("Finished hmmsearch.");
}

=head2 collect_best_hmm_hits

Parse all the hmmsearch output files and collect the ids of the best hit per gene and proteome
Additionally an absence presence table is written to absence_presence.csv for later inspection

=cut

sub collect_best_hmm_hits{
	my $self = shift;
	my %proteome = %{$self->{proteome}};
	my $out = $self->{'outdir'};
	$L->info("Collecting best hits from hmmsearch for each gene.");
	my %gene_id_map;
	my %absence_presence;
	foreach my $p (keys %proteome){
		open(IN, "<$out/$p.hmmsearch.tsv") or $L->logdie("Error opening $out/$p.hmmsearch.tsv. $!");
		while(<IN>){
			next if(/^#/);
			s/ * / /g;
			my($id,$gene,$score) = (split(/\s/))[0,3,5];
			$gene_id_map{$gene}->{$p} = {id => $id, score => $score} unless(exists $gene_id_map{$gene}->{$p} and $gene_id_map{$gene}->{$p}->{score}>$score);
			$absence_presence{$gene}->{$p} = 0 unless(exists $absence_presence{$gene}->{$p});
			$absence_presence{$gene}->{$p}++;
		}
		close IN or $L->logdie("Error closing $out/$p.hmmsearch.tsv. $!");
	}
	foreach my $g (keys %gene_id_map){
		open(OUT, ">$out/$g.ids") or $L->logdie("Error opening $out/$g.ids. $!");
		my $count = 0;
		foreach my $id (map {$gene_id_map{$g}{$_}{id}} keys %{$gene_id_map{$g}}){
			print OUT "$id\n";
			$count++;
		}
		$L->info("Wrote $count ids for gene $g");
		if($count < $self->{'min-proteomes'}){
			$L->warn("Gene $g only present in $count proteome - removing from further analyses");
			delete $gene_id_map{$g};
		}
		close OUT or $L->logdie("Error closing $out/$g.ids. $!");
	}
	# Add the remaining list of genes to the object
	$self->{genes} = [keys %gene_id_map];
	$L->logdie("Not a single gene is present in more than one proteome - Exiting") if((keys %gene_id_map) < 1);
	# Write absence presence list
	open(OUT, ">$out/absence_presence.csv") or $L->logdie("Error opening $out/absence_presence.csv. $!");
	print OUT ",".join(",", sort keys %proteome)."\n";
	foreach my $gene (sort keys %absence_presence){
		print OUT "$gene";
		foreach my $p (sort keys %proteome){
			my $s = "0";
			$s = $absence_presence{$gene}->{$p} if(exists $absence_presence{$gene}->{$p});
			print OUT ",$s";
		}
		print OUT "\n";
	}
	close OUT or $L->logdie("Error colsing $out/absence_presence.csv. $!");
	$L->info("Finished collection of best hmmsearch hits.");
}

sub get_sequences_of_best_hmm_hits{
	my $self = shift;
	my @genes = @{$self->{genes}};
	my $out = $self->{'outdir'};
	my $separator = $self->{'separator'};
	$L->info("Collecting sequences of best hits from hmmsearch for each gene.");
	foreach my $gene (@genes){
		my $cmd = "$FindBin::RealBin/../SeqFilter/bin/SeqFilter --ids-rename='s/$separator.*//' --desc-replace --line-width 0 $out/all.concat.fa --ids $out/$gene.ids --out $out/$gene.fa 2>&1";
		$self->run_command($cmd, "collect best hits for $gene");
	}
	$L->info("Finished collection of sequences of best hits from hmmsearch.");
}

sub run_muscle_and_gblocks{
	my $self = shift;
	my @genes = @{$self->{genes}};
	my $out = $self->{'outdir'};
	my %proteome_id_map = reverse %{$self->{proteome_map}};
	$L->info("Running muscle and Gblocks on gene sets.");
	foreach my $gene (@genes){
		# muscle
		my $cmd = $self->{'muscle-bin'}." -align $out/$gene.fa -output $out/$gene.aln";
		$self->run_command($cmd, "muscle on $gene");
		# Gblocks
		$cmd = $self->{'gblocks-bin'}." $out/$gene.aln -t=p -b4=4 -b5=h";
		# Ignore exit code for Gblocks as this is always 1, rather test for error string manually.
		my $r = $self->run_command($cmd, "Gblocks on $gene", 1);
		$L->logdie("ERROR: Gblocks on $gene failed") if($r=~/Execution terminated/);
		# Removel of unnecessary spaces
		my $seqIn = Fasta::Parser->new(file => "$out/$gene.aln-gb", mode => "<");
		my $seqOut = Fasta::Parser->new(file => "$out/$gene.aln-gb.fa", mode => ">");
		while(my $seq = $seqIn->next_seq){
			$seq->id($proteome_id_map{$seq->id()});
			my $s = $seq->seq;
			$s =~ s/\s+//g;
			$seq->seq($s);
			$seqOut->append_seq($seq);
		}
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
	my $totalpos = 0;
	$L->info("Completing and concatenating alignments.");
	open(PART, ">$out/full_alignment.concat.partition") or $L->logdie("Error opening $out/full_alignment.concat.partition. $!");
	foreach my $gene (sort @genes){
		unless(-f "$out/$gene.aln-gb.fa"){
			$L->warn("No Gblocks file for gene $gene - most likely only found in one proteome. Skipping...");
			next;
		}
		my %seq = ();
		my $length = 0;
		my $seqIn = Fasta::Parser->new(file => "$out/$gene.aln-gb.fa", mode => "<");
		while(my $seq = $seqIn->next_seq){
			$seq{$seq->id} = $seq->seq;
			$length = length($seq->seq);
		}
		print PART $self->{'raxml-aa-substitution-model'}.", $gene = ".($totalpos+1)."-";
		$totalpos += $length;
		print PART $totalpos."\n";
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
	close PART or $L->logdie("Error closing $out/full_alignment.concat.partition. $!");
	open(OUT, ">$out/full_alignment.concat.fa") or $L->logdie("Error opening $out/full_alignment.concat.fa. $!");
	foreach my $p (sort keys %proteome){
		print OUT ">$p\n";
		print OUT "$fullseq{$p}\n";
	}
	close OUT or $L->logdie("Error closing $out/full_alignment.concat.fa. $!");
	$L->info("Completing and concatenating alignments finished.");
}

sub run_raxml{
	my $self = shift;
	my $out = $self->{'outdir'};
	my $msg = "raxml on $out/full_alignment.concat.fa";
	my $cmd = $self->{'raxml-bin'}." -f a -m GTRGAMMA -p ".$self->{'raxml-p'}." -q $out/full_alignment.concat.partition -s $out/full_alignment.concat.fa -w ".File::Spec->rel2abs( $out )." -n final -T ".$self->{'threads'}." -x ".$self->{'raxml-x'}." -N ".$self->{'bootstraps'}." ".$self->{'raxml-args'};
	$self->run_command($cmd, $msg);
	$L->info("Finished bcgTree.");
}

sub run_command{
	my $self = shift;
	my $cmd = shift;
	my $msg = shift;
	my $ignore_error = shift;
	$L->info("Starting: $msg");
	$L->info($cmd);
	my $result = qx($cmd);
	$L->debug($result);
	$L->logdie("ERROR: $msg failed") if $? >> 8 and !$ignore_error;
	$L->info("Finished: $msg");
	return $result;
}

1;

=head1 AUTHORS

=over

=item * Markus Ankenbrand, markus.ankenbrand@uni-wuerzburg.de

=item * Alexander Keller, a.keller@biozentrum.uni-wuerzburg.de

=back

