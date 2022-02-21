'''
Script para convertir un archivo de bed a gtf
'''

import argparse


class bed12_transcript:
    
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
        rgb_str = ",".join([str(i) for i in self.RGB])
        exon_lenght_str = ",".join([str(i) for i in self.exon_length])
        exon_start_str = ",".join([str(i) for i in self.exon_start])
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

        for exon in self.exons:
            gtf_transcript_str += "\n" + str(exon)
        return gtf_transcript_str

class gtf_exon():

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
    l_exons = list()
    gtf_start = bed_record.start + 1
    for i in range(bed_record.n_exons):
        exon_start = gtf_start + bed_record.exon_start[i]
        exon_end = exon_start + bed_record.exon_length[i] - 1
        gtf_record = gtf_exon(bed_record.chr, "isoseq3",
                                start=exon_start,
                                end=exon_end, 
                                strand=bed_record.strand,
                                gene_id=bed_record.gene_id,
                                transcript_id=bed_record.transcript_id)
        l_exons.append(gtf_record)
    return l_exons


def bed2gtf(bed_record:bed12_transcript)-> gtf_transcript:
    gtf_start = bed_record.start + 1
    l_exons = bed2exon(bed_record)
    gtf_record = gtf_transcript(bed_record.chr, "isoseq3", start=gtf_start,
                                end=bed_record.end, strand=bed_record.strand,
                                gene_id=bed_record.gene_id,
                                transcript_id=bed_record.transcript_id,
                                exons=l_exons)
    return gtf_record


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("bed")
    #parser.add_argument("gtf")
    args = parser.parse_args()
    gtf = args.bed.split(".")[0] + ".gtf"
    f_out = open(gtf, "w")
    with open(args.bed, "r") as f_in:
        for line in f_in:
            bed_record = parse_bed12(line)
            gtf_record = bed2gtf(bed_record)
            f_out.write(str(gtf_record) + "\n")
    f_out.close()

if __name__=="__main__":
    main()
