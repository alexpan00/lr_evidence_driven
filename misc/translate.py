'''
Script to translate a fasta file
'''
from Bio import SeqIO 

def main():
    l_records = []
    record_iterator = SeqIO.parse("transcript_LO.fasta", "fasta")
    for record in record_iterator:
        record.seq = record.seq.translate(to_stop=True)
        l_records.append(record)
    SeqIO.write(l_records, "transcript_LO.faa" ,"fasta")

if __name__=="__main__":
    main()