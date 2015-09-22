#!/bin/bash

INSTALL_DIR=~/projects/core-genome-tree-builder
ESSENTIAL_HMM=${INSTALL_DIR}/data/essential.hmm
SEQFILTER_BIN=${INSTALL_DIR}/SeqFilter/bin/SeqFilter

for i in *
do
    cat $i/*.faa >$i.pep.fa
    # rename ids to include species name as prefix (separated from ID by _-_)
    perl -i -pe 's/^>/>'$i'_-_/' $i.pep.fa
    hmmsearch --tblout $i.hmm.tsv --cut_tc --notextw $ESSENTIAL_HMM $i.pep.fa > $i.hmm.txt
    tail -n+4 $i.hmm.tsv | sed 's/ * / /g' | cut -f1,4 -d " " --output-delimiter $'\t' | grep -v "^#" | sort -u > $i.essential_genes.tsv
    cat $i.hmm.tsv | grep -v "^#" | sed 's/ * / /g' | perl -F'\s' -ane 'open OUT, ">>$F[3].ids" or die $!; print OUT "$F[0]\n"; close OUT or die $!;'
done

for i in *.ids
do
    BASE=$(basename $i .ids)
    cat *.pep.fa | $SEQFILTER_BIN --in - --ids $i --out $BASE.fa 2>>sequences.log
done
perl -i -pe 's/_-_/ /g' *.fa
