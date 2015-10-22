#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Log::Log4perl qw(:no_extra_logdie_message);

my %options;

=head1 NAME

bcgTree.pl

=head1 DESCRIPTION

Wrapper to produce phylogenetic trees from the core genome (107 essential genes) of bacteria.

=head1 USAGE

  $ bcgTree.pl --genome bac1=bacterium1.pep.fa --genome bac2=bacterium2.faa [options]

=head1 OPTIONS

=over 25

=item --proteome <ORGANISM>=<FASTA> [--proteome <ORGANISM>=<FASTA> ..]

Multiple pairs of organism and proteomes as fasta file paths

=cut

$options{'proteome|p=s%'} = \( my $opt_proteome );

=item [--prefix <STRING>]

prefix for the generated output files (default: cgtb)

=cut

$options{'prefix=s'} = \( my $opt_prefix="cgtb" );

=item [--help] 

show help

=cut

$options{'help|?'} = \( my $opt_help );

=back


=head1 CODE

=cut

GetOptions(%options) or pod2usage(1);
pod2usage(1) if ($opt_help);

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
check_existence_of_fasta_files();

sub check_existence_of_fasta_files{
	foreach(keys %{$opt_proteome}){
	    $L->logdie("File not found: ".$opt_proteome->{$_}) unless(-f $opt_proteome->{$_});
	}
}

=head1 AUTHORS

=over

=item * Markus Ankenbrand, markus.ankenbrand@uni-wuerzburg.de

=item * Alexander Keller, a.keller@biozentrum.uni-wuerzburg.de

=back

