Examples to show how the long read pipelines, FLAIR and Isoseq3 were run.
All the data used was downloded from ENCODE. For the PacBio data the subreads
were downloaded. For the ONT data the starting point was the fastq files.

For more information about the pipelines and the data:
Isoseq3: https://github.com/PacificBiosciences/IsoSeq
FLAIR: https://github.com/BrooksLabUCSC/flair
Data: https://hgwdev.gi.ucsc.edu/~markd/lrgasp/rnaseq-data-matrix.html

The initial part of the PacBio data processing has to be done with the Isoseq3
pipeline. FLAIR is run the full lenght non chimeric reads.

After running the the long read pipelines the quality control software SQANTI3
was run on the produced transcriptomes.

For more information about how to install and run SQANTI3:
 SQANTI3: https://github.com/ConesaLab/SQANTI3
 SQANTI3 LRGASP versions: https://github.com/LRGASP