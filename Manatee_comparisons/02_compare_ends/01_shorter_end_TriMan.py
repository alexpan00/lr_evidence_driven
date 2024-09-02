'''
Script to read the SQANTI3 classification file and select those transcripts of
the TriManLat annotation that have shorter end, i.e ISM or FSM with shorter ends
compared to the LRB annotation (FSM alternative 3' 5' or both)
'''

import pandas
import argparser


def parse_arguments()-> argparser:
    '''Create a parser object
    
    Returns: parser object
    '''
    
    parser = argparser.ArgumentParser(description='Select transcripts with shorter ends')
    parser.add_argument('-s', '--sqanti', help='SQANTI3 classification file')
    parser.output('-o', '--output', help='Output file')
    
    args = parser.parse_args()
    
    return args

def main():
    
    # Read the SQANTI3 classification file
    args = parse_arguments()
    classification = pandas.read_csv(args.sqanti, sep='\t')
    
    # Select transcript in which structural_category column is full-splice_match
    # or incomplete-splice_match and the end is shorter than the LRB annotation
    shorter_ends = classification[(classification['structural_category'] == 'full-splice_match') | 
                                  (classification['structural_category'] == 'incomplete-splice_match')]
    
    # Keep all the ISM and for FSM, select those with alternative 3' or 5' end, i.e. subcategory 
    # column starts with 'alternative' and shorter ends
    shorter_ends = shorter_ends[((shorter_ends['structural_category'] == 'full-splice_match') & 
                                (shorter_ends['subcategory'].str.startswith('alternative')) &
                                ((shorter_ends['diff_to_TSS'] > 0 | 
                                 shorter_ends['diff_to_TTS'] > 0))) |
                                (shorter_ends['structural_category'] == 'incomplete-splice_match')]
    
    # write the selected transcripts to a file, only the transcript ID (isoform)
    # and the reference transcript ID (associated_transcript)
    shorter_ends[['isoform', 'associated_transcript']].to_csv(args.output, sep='\t', index=False)
