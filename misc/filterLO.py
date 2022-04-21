'''
Script to get the longest orf with start and stop codons
'''
from Bio import SeqIO 

def main():
    # Dictionary to store the accepted transcript for each gene
    gene_dict = dict()
    
    # Accepted stop codons 
    stop_codon = ["TAA", "TGA", "TAG"]
    record_iterator = SeqIO.parse("transcripts.fasta", "fasta")

    # iterate on the multifasta (each record is a transcript)
    for record in record_iterator:
        gene = record.description.split()[1].split("=")[1]

        # check if the transcript has a valid start and end
        if record.seq.startswith("ATG") and record.seq[-3:] in stop_codon:

            # add valid transcript to the dict
            if gene in gene_dict.keys():
                gene_dict[gene].append(record)
            else:
                gene_dict[gene] = [record]
    
    # List to store the transcript with the longest orf for each gene 
    l_records = list()
    for gene in gene_dict.keys():
        max_len = 0
        i = 0
        # For each gene find the transcript with the longest orf
        for index, sequence in enumerate(gene_dict[gene]):
            if len(sequence.seq) > max_len:
                max_len = len(sequence.seq)
                i = index
        print(i, len(gene_dict[gene]))
        l_records.append(gene_dict[gene][i])

    # Save the transctipt with the longest ORF in fasta format
    SeqIO.write(l_records, "transcript_LO.fasta" ,"fasta")

if __name__=="__main__":
    main()
