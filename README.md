# Eukaryotic Genome Annotation Using Long Reads

## Overview

This repository contains the code, data, and supplementary materials for the paper:

**Evaluation of strategies for evidence-driven genome annotation using long-read RNA-seq** 

**Authors:** Alejandro Paniagua, Cristina Agustín

## Abstract

The aim of this project is to test the most effective approach for using long reads in the structural annotation of genomes and to apply this strategy to annotate the Florida manatee genome. The scripts in this repository provide tools to evaluate different methods for incorporating long reads into genome annotation, from testing on a known genome to annotating an unannotated genome.


## Project Details

### Long Reads for Genome Annotation

The main objective is to evaluate which third-generation sequencing technology—PacBio, Oxford Nanopore, or a combination of both—is most effective, and at which stage of structural annotation they perform best.

The two key steps where long reads can be utilized in structural annotation are:
1. **Training of Hidden Markov Models (HMM)**
2. **Providing external evidence during gene prediction**

#### Training HMMs with Long Reads

To use long reads for HMM training, genes must first be identified in the reads. Identifying genes in transcripts is easier than in the genome due to the limited search space and absence of introns.

The `long_reads` folder contains scripts for running two pipelines, FLAIR and Isoseq, to generate transcripts. After running these pipelines, SQANTI3 should be used for quality control and coding transcript prediction.

However, the resulting transcripts often exhibit redundancy and inaccuracies. Redundancy and errors must be minimized to train an HMM for gene prediction. The `class2GB` script offers filtering methods to obtain a reliable set of genes for HMM training.

The `testFR` script allows for the training and testing models with different flanking regions and training set sizes.

#### Using Long Reads as External Evidence

Long reads can also be used as external evidence during the gene prediction step. The necessary scripts for this application are located in the `hints` folder.

### Scripts Overview

- **FLAIR and Isoseq3 Pipelines:** Generate transcripts from long reads.
- **SQANTI3:** Quality control and coding transcript prediction.
- **class2GB:** Filter transcripts to reduce redundancy and errors for HMM training.
- **testFR:** Train and test HMMs with varying parameters.
- **Hints Scripts:** Use long reads as external evidence in gene prediction.

### Versions

Some scripts have two versions:
- **WTC11 Version:** Designed to test results against a known reference annotation.
- **Normal Version:** Designed for annotating new species.


### Manatee results
The final Floria manatee annotation, as well as the experimental evidence used to run AUGUTUS, can be foun in [Manatee annotation](https://github.com/alexpan00/lr_evidence_driven/tree/3467d6a84e9dee9dfa2d3e35374b6dda6d47cfe5/Manatee_annotaion)
