'''
Script that uses a filtered classification file (SQANTI3 output) to filter
a sam file and keep only the transcripts present in the classification file
'''

import argparse
import os

def parse_classification(classification: str)-> list:
    '''
    Function to parse the classification file and keep only the names of the
    transcripts
    
    Input:
        classification (str): path to the classification file
    
    Output:
        l_trasncripts (list): list of the transcripots ids
    ''' 
    l_transcripts = list()
    # Read the SQANTI3 filtered classification file
    with open(classification, "r") as f_in:
        # Parse every line except the header
        header_line = next(f_in)
        for i, linea in enumerate(f_in):
            ll = linea.split()
            # The trasncript id is the first fild of the line
            l_transcripts.append(ll[0])
    return l_transcripts

def main():
    parser = argparse.ArgumentParser(description="Filter a SAM file keeping only the transcript present in the filtered SQANTI3 classification file")
    # Classification file
    parser.add_argument("classification", 
                        help="SQANTI classification file")
    # Sam file
    parser.add_argument("sam",
                        help="SAM file to be filtered")
    parser.add_argument("out_dir",
                        help="path to write the output")
    args = parser.parse_args()
    # Read the transcript in the filtered classification file
    l_transcripts = parse_classification(args.classification)
    # Open the new sam file
    sam_basename = os.path.basename(args.sam)
    f_out = open(args.out_dir + "/" + "filtered_" + sam_basename, "w")
    # Open the sam that will be filtered
    with open(args.sam, "r") as f_in:
        for linea in f_in:
            # Write the sam header
            if linea.startswith("@"):
                f_out.write(linea)
            # Write the transcripts
            else:
                ll = linea.split()
                # The first fild in the sam line is the transcriot id, if it is
                # in the list of selected trasncripts it is written to the 
                # final output
                if ll[0] in l_transcripts:
                    f_out.write(linea)
    f_out.close()
    
if __name__=="__main__":
    main()