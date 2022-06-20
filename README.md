# Eukaryotic genome structural annotation using long reads

This is the repository of my master thesis. The aim of this project is testing
the best approach to use long reads in the structural annotation of genomes and
use that strategy the annotate the florida manatee genome. 

To do so, the scripts in this repository provide a set of tools to test different
ways in which long reads can be used in genome annotation and also the necesary
resources to apply from testing on a known genome to an unannotated genome.

## Long reads for genome annotation

The main idea of this project was testing what kind of third generation sequencing
technology, PacBio, Oxford Nanopore or the combiantion of both, and in which step
of the strucutral annotation would work better.

The two steps in which the long reads data can be used for the structural annotaion
are the training of the Hidden Markov Models (HMM) and as external evidence during
the prediction of the genes.

To use the long reads to train a HMM, first genes must be identified in those 
reads. The process of identifying a gene in a transcript is much easier than
finding the same gene in the genome mainly for two reasons, the space of search
is much more limited and there are no introns.

The scripts in the long_reads folder provide examples on how to run two different 
pipelines, FLAIR and Isoseq3 to generate transcripts. After running this pipelines
SQANTI3 should be run on the resulting transcriptomes both for quality control and
prediction of coding transcripts. However, there is a lot of redundancy in the
resulting transcripts with many isoforms per gene and also wrongly define trainscripts. 
To train a HMM for gene prediction this kind of redudancy and errors should be avoided. 
In order to limit the redundancy and the number of false transcripts the class2GB
script provides different filtering methods to obtain a set of reliable genes that
can be used to train a HMM for gene prediction.

As mentioned before the other step in which long reads can be used for genome 
annotation is as evidence during the gene prediction step. The necesary script
to use long reads as external evidence can be found in the hints folder.



