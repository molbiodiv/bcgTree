#!/usr/bin/perl -w

use strict;
use warnings;
use lib('/usr/lib/perl5/5.8.8');

#qx(grep ">" *.fa.aln-gb | cut -d ">" -f 2 | sort | uniq > all.taxa.txt);
qx(grep ">" *.fa.aln-gb | cut -d ">" -f 2 | sed "s/[[:space:]]gi\|.*//g" | sed "s/[[:space:]]fig//g" | sed "s/\|.*//" | sort | uniq > all.taxa.txt);

my @files = qx(ls *.fa.aln-gb);
my @taxa = qx(cat all.taxa.txt);
#print "@taxa \n";
chomp(@taxa);

my $status= "header";
my $position_from;
my $position_to = 0;

qx(rm concatenated.partitions.txt);
qx(rm concatenated.fa);
qx(rm *.comp);

foreach my $file (@files){
	$position_from= $position_to+1;
	chomp($file);
	my $input = qx(cat $file);	

	my @input = split (/>/, $input);
	shift(@input);
	#print ">>$input[0]<<";
	
	my %seqs;
	my $output = "";
	my $length;
	
	foreach my $tmp_input (@input){
		my @tmp_input = split (/\n/, $tmp_input);
			$tmp_input[0] =~ s/\s.*$//;
			my ($tmp_header) = $tmp_input[0];			
						
			shift(@tmp_input);
			chomp(@tmp_input);
			my $tmp_seq= join("",@tmp_input);

			$seqs{$tmp_header}=$tmp_seq;	
			$length = length($tmp_seq);
	}
	foreach my $tmp_taxa (@taxa){
#	  print ">>$tmp_taxa<<\n" ;
	  my @test = keys(%seqs);
#	  print "!!$test[0]!!\n" ;

		if (grep {$_ eq $tmp_taxa} keys(%seqs)) {
  #			print "Element '$tmp_taxa' found!\n" ;
			$output .= ">$tmp_taxa\n";
			$output .= "$seqs{$tmp_taxa}\n";

		}else{
#		  	print "Element '$tmp_taxa' NOTfound!\n" ;
			$output .= ">$tmp_taxa\n";
			$output .= '-' x $length;
			$output .= "\n";
		}
	}
	
	$position_to = $position_to+$length;
	
	open(my $OP, '>', "$file.comp");
		print $OP "$output";
	close $OP;

	open(my $PART, '>>', "concatenated.partitions.txt");
		print $PART "WAG, $file=$position_from-$position_to\n";
	close $PART;

}

qx(paste -d \'\\0\' *.comp > concatenated.fa);
qx(sed -i.bak  \"s\/\\\(>\[\^>\]*\\\)>\.\*\$\/\\1\/g\" concatenated.fa );
qx(mkdir 3_complemented);
qx(mv  *.comp 3_complemented/);
qx(mv  *.aln-gb 2_gblocks/);

qx(sed -i.bak  \"s\/\\\(>\[\^>\]\*\\\)>\.\*\$\/\\1\/g\" concatenated.fa); 
qx(./raxml -f a -m GTRGAMMA -p 12345 -q concatenated.partitions.txt -s concatenated.fa -n PART02 -T 2 -x 12345 -# 10) 
