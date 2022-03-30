'''
Script to convert from bed to gtf
'''


import argparse


class bed12_transcript:
    '''
    Class to storage the information of a bed12 file line (a transcript)

    Attributes:
    ----------
    chr (str): chromosome
    start (int): starting position of the transcript (0 based, inclusive)
    end (int): final position of the transcript (0 based, not inclusive)
    gene_id (str): name of the gene
    transcript_id (str): name of the transcript
    score (int): a score of the feature
    strand (str): can be + or - strand of the chromoseme
    thick_star (int): generally, the start of the CDS
    thick_end (int): generally the end of the CDS
    RGB (list): list of int to add color when reperesenting the feature
    n_exons (int): number of exons of the transcript
    exon_length (list): a list of int with the length of each exon
    exon_start (list): a list of int with the starting position of each exon

    Methods:
    --------
    __str__: convert the bed12_trancript to a str
    '''
    def __init__(self, 
                chr = "",
                start = 0,
                end = 0,
                gene_id = "",
                transcript_id = "",
                score = 0,
                strand = "+",
                thick_start = 0,
                thick_end = 0,
                RGB = [0,0,0],
                n_exons = 0,
                exon_length = [],
                exon_start = []):
        self.chr = chr
        self.start = start
        self.end = end
        self.gene_id = gene_id
        self.transcript_id = transcript_id
        self.score = score
        self.strand = strand
        self.thick_start = thick_start
        self.thick_end = thick_end
        self.RGB = RGB
        self.n_exons = n_exons
        self.exon_length = exon_length
        self.exon_start = exon_start


    def __str__(self) -> str:
        '''
        Convert the bed12_transcript to a str

        Output:
            str: a transcript in bed12 format
        '''
        # Create str from the attributes that are lists.
        rgb_str = ",".join([str(i) for i in self.RGB])
        exon_lenght_str = ",".join([str(i) for i in self.exon_length])
        exon_start_str = ",".join([str(i) for i in self.exon_start])
        
        # Concatenate all the ettributes and separate them by \t
        bed_str = self.chr \
            + "\t" + str(self.start)\
            + "\t" + str(self.end)\
            + "\t" + self.gene_id\
            + ";" + self.transcript_id\
            + "\t" + str(self.score)\
            + "\t" + self.strand\
            + "\t" + str(self.thick_start)\
            + "\t" + str(self.thick_end)\
            + "\t" + rgb_str\
            + "\t" + str(self.n_exons)\
            + "\t" + exon_lenght_str\
            + "\t" + exon_start_str
        return bed_str


class gtf_transcript():
    '''
    Class to storage the information of a transcript with gtf features

    Attributes:
    ----------
    chr (str): chromosome
    source (str): the source of the information used to define the treanscript
        examples: AUGUSTUS, PacBio, ENSEMBL, GENCODE
    feature (str): the feature that is represented. 
        In this case always transcript
    start (int): starting position of the transcript (1 based, inclusive)
    end (int): final position of the transcript (1 based, inclusive)
    score (int): a score of the feature
    strand (str): can be + or - strand of the chromoseme
    frame (str): can be .,1,2,3 ORF of the CDS
    gene_id (str): name of the gene
    transcript_id (str): name of the transcript
    exons (list): list of gtf exon object representing the exons of the 
        transcript

    Methods:
    --------
    __str__: convert the gtf_transcript object to a str
    '''
    def __init__(self,
                chr = "",
                source = "",
                feature = "transcript",
                start = 1,
                end = 1,
                score = ".",
                strand = "+",
                frame = ".",
                gene_id = "",
                transcript_id = "",
                exons = []):
        self.chr = chr
        self.source = source
        self.feature = feature
        self.start = start
        self.end = end
        self.score = score
        self.strand = strand
        self.frame = frame
        self.gene_id = gene_id
        self.transcript_id = transcript_id
        self.exons = exons
    
    def __str__(self) -> str:
        '''
        convert the gtf_transcript object to a str

        output:
            str: gtf format transcript with exons
        '''
        # Concatenate the attributes using \t or ; to generate a gtf format str
        gtf_transcript_str = self.chr \
            + "\t" + self.source\
            + "\t" + self.feature\
            + "\t" + str(self.start)\
            + "\t" + str(self.end)\
            + "\t" + str(self.score)\
            + "\t" + self.strand\
            + "\t" + self.frame\
            + "\t" + 'gene_id "' + self.gene_id + '"; transcript_id "'\
            + self.transcript_id + '";'

        # Convert the exon list to gtf format str
        for exon in self.exons:
            gtf_transcript_str += "\n" + str(exon)
        return gtf_transcript_str

class gtf_exon():
    '''
    Class to storage the information of an exon with gtf features

    Attributes:
    ----------
    chr (str): chromosome
    source (str): the source of the information used to define the exon
        examples: AUGUSTUS, PacBio, ENSEMBL, GENCODE
    feature (str): the feature that is represented. 
        In this case always exon
    start (int): starting position of the exon (1 based, inclusive)
    end (int): final position of the exon (1 based, inclusive)
    score (int): a score of the feature
    strand (str): can be + or - strand of the chromosome
    frame (str): can be .,1,2,3 ORF of the CDS
    gene_id (str): name of the gene
    transcript_id (str): name of the transcript

    Methods:
    --------
    __str__: convert the gtf_exon object to a str
    '''
    def __init__(self,
            chr = "",
            source = "",
            feature = "exon",
            start = 1,
            end = 1,
            score = ".",
            strand = "+",
            frame = ".",
            gene_id = "",
            transcript_id = ""):
        self.chr = chr
        self.source = source
        self.feature = feature
        self.start = start
        self.end = end
        self.score = score
        self.strand = strand
        self.frame = frame
        self.gene_id = gene_id
        self.transcript_id = transcript_id


    def __str__(self) -> str:
        '''
        convert the gtf_exon object to a str

        output:
            str: gtf format exon
        '''
        # Concatenate all the attributes using \t or ;
        gtf_exon_str = self.chr \
            + "\t" + self.source\
            + "\t" + self.feature\
            + "\t" + str(self.start)\
            + "\t" + str(self.end)\
            + "\t" + str(self.score)\
            + "\t" + self.strand\
            + "\t" + self.frame\
            + "\t" + 'gene_id "' + self.gene_id + '"; transcript_id "'\
            + self.transcript_id + '";'
        
        return gtf_exon_str


def parse_bed12(record: str)-> bed12_transcript:
    '''
    Function to parse a line of a bed12 file and convert it to a 
    bed12_transcript object

    Inputs:
        record (str): a line of a bed12 file

    Outputs:
        parsed_record (bed12_transcript): bed12 transcript information
    '''
    # Assign every field to its corresponding attribute
    # Some of the filds need another spliting to be stored in a list
    record_filds = record.split()
    chr = record_filds[0]
    start = int(record_filds[1])
    end = int(record_filds[2])
    gene_id, transcript_id = record_filds[3].split(";")
    score = int(record_filds[4])
    strand = record_filds[5]
    thick_start = int(record_filds[6])
    thick_end = int(record_filds[7])
    RGB = ([int(i) for i in record_filds[8].split(",")])
    n_exons = int(record_filds[9])
    exon_length = ([int(i) for i in record_filds[10].split(",")])
    exon_start = ([int(i) for i in record_filds[11].split(",")])

    # Create the bed12_trancript object with the record information
    parsed_record = bed12_transcript(chr,
                                        start,
                                        end,
                                        gene_id,
                                        transcript_id,
                                        score,
                                        strand,
                                        thick_start,
                                        thick_end,
                                        RGB,
                                        n_exons,
                                        exon_length,
                                        exon_start)
    
    return parsed_record


def bed2exon(bed_record:bed12_transcript)-> list:
    '''
    Fuction to convert a bed12_transcript to a list of gtf_exons

    One of the main considerations in the transformation from bed to gtf is 
    that bed is 0 based and the last position is not inclusive while bed is
    1 based and last position is inclusive

    Inputs:
        bed_record (bed12_transcript): bed record that will be converted to 
            gtf format

    Outputs:
        l_exons (list): a list of gtf_exons 
    '''
    l_exons = list()
    # Convert the start from 0 based to 1 based
    gtf_start = bed_record.start + 1
    for i in range(bed_record.n_exons):
        # BED file stores the starting postions of the exons in realtion
        # to the the start of the transcript. To get the absolute position
        # the exon starting position should be added to the gtf starting 
        # position
        exon_start = gtf_start + bed_record.exon_start[i]

        # BED file stores the lenght of the exons. To get the absolute 
        # position of the end of the exon the lenght is added to the starting
        # position of the exon. Since gtf format features ends are inclusive 
        # and it is one based and one base was previously added to the start
        # one base is substracted from the end to get the appropiate end.
        exon_end = exon_start + bed_record.exon_length[i] - 1

        # Create a gtf_exon object
        gtf_record = gtf_exon(bed_record.chr, "isoseq3",
                                start=exon_start,
                                end=exon_end, 
                                strand=bed_record.strand,
                                gene_id=bed_record.gene_id,
                                transcript_id=bed_record.transcript_id)
        
        # Add all the gtf_exon object comming from the same transcripts to
        # a list
        l_exons.append(gtf_record)
    return l_exons


def bed2gtf(bed_record:bed12_transcript)-> gtf_transcript:
    '''
    Function to convert bed12_transcriot to gtf_transcript

    One of the main considerations in the transformation from bed to gtf is 
    that bed is 0 based and the last position is not inclusive while bed is
    1 based and last position is inclusive

    Inputs:
        bed_record (bed12_trasncript): BED12 format transcript
    
    Outputs:
        gtf_transcript: GTF format transcript
    '''
    # Convert the start from 0 based to 1 based
    gtf_start = bed_record.start + 1

    # Get the exons in gtf format
    l_exons = bed2exon(bed_record)

    # Save the transcript in gtf format
    gtf_record = gtf_transcript(bed_record.chr, "isoseq3", start=gtf_start,
                                end=bed_record.end, strand=bed_record.strand,
                                gene_id=bed_record.gene_id,
                                transcript_id=bed_record.transcript_id,
                                exons=l_exons)
    return gtf_record


def main():
    parser = argparse.ArgumentParser(description="Convert BED12 to GTF")
    parser.add_argument("bed",
                        help="Path to the bed file to be converted")
    #parser.add_argument("gtf")
    args = parser.parse_args()
    
    # Get the name of the file wo/ extension and add gtf to get the final
    # name
    gtf = args.bed.split(".")[0] + ".gtf"
    f_out = open(gtf, "w")
    # Each of the lines of the bed12 file is a transcriot that will be
    # converted to gtf format
    with open(args.bed, "r") as f_in:
        for line in f_in:
            bed_record = parse_bed12(line)
            gtf_record = bed2gtf(bed_record)
            f_out.write(str(gtf_record) + "\n")
    f_out.close()

if __name__=="__main__":
    main()