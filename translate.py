'''
Script que permite traducir un fasta
'''
import os
import Bio 

def main():
    l_records = []
    record_iterator = SeqIO.parse("prueba_ref.fa", "fasta")
    for record in record_iterator:
        print(record.Seq.translate())

if __name__=="__main__":
    main()