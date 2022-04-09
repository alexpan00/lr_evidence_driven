'''
Script to read the file of isoform-read realtion produce using FLAIR and
generate and count file, reanme the isoforms, both in that file and in the
multifasta file with the isoform sequences
'''


import argparse


def count_rename(in_file: str, name: str, wd: str)-> dict:
    '''
    Function to get the counts of the isoforms and rename them

    Inputs:
        in_file (str): path to the isoform-read relation produce by FLAIR
        name (str): name for the counts file
        wd (str): path to with the results of running FLAIR
    
    Outputs:
        d_names (dict): a dictionary that relates the old isoform name to the 
                        new isoform name
    '''
    # Dict to relate the old isoform name to the new name
    d_names = dict()
    # file to write the counts
    out_file = wd + "/" + name + ".counts.tsv"
    # Write the header for SQANTI3 to read it
    f_out = open(out_file, "w")
    f_out.write("pbid\tcount_fl\n")
    # Read the file with the isoform-read relation
    with open(in_file, "r") as f_in:
        for i, linea in enumerate(f_in,1):
            # Each line has the isoform and the related reads
            transcript, reads = linea.split()
            # Give the isoform a more readable name
            new_name = "ONT" + str(i)
            # Add the isoform to the dicctionary
            d_names[transcript] = new_name
            # Count the number of read associated to the transcript, the
            # read ids are separated by "," so the len of the lsit is the 
            # number of reads
            n_reads = str(len(reads.split(","))) 
            # Write the isoform new name and the number of associated reads
            f_out.write(new_name + "\t" + n_reads + "\n")
    
    f_out.close()
    return d_names

def rename_fasta(d_names: dict, prefix: str, wd: str):
    '''
    Function to rename the isoforms in the multifasta file produce by FLAIR
    and make the name of the isoforms more readable.

    Inputs:
        d_names (dict): a dictionary that relates the old isoform name to the
                        new isoform name
        prefix (str): name of the FLAIR outputs wo/ the extencsion
        wd (str): path to with the results of running FLAIR
    '''
    in_file = wd + "/" + prefix + ".isoforms.fa"
    out_file = wd + "/renamed_" + prefix + ".isoforms.fa"
    f_out = open(out_file, "w")
    with open(in_file, "r") as f_in:
        for linea in f_in:
            # Replace the headers in the multifasta file
            if linea.startswith(">"):
                transcript = linea.strip(">").rstrip()
                new_name = d_names[transcript]
                f_out.write(">" + new_name + "\n")
            # if it is not a header write the sequence as it is
            else:
                f_out.write(linea)
    f_out.close()

def main():
    parser = argparse.ArgumentParser(description="Count the number of trasncripts per read and rename the trasncriopts")
    parser.add_argument("prefix",
                        help="Prefix of the FLAIR output files")
    parser.add_argument("wd",
                        help="Path to the FLAIR outputs") 
    args = parser.parse_args()
    # Path to the isoform-read relation file
    in_file_counts = args.wd + "/" + args.prefix + ".isoform.read.map.txt"
    # Counts and new names
    d_names = count_rename(in_file_counts, args.prefix, args.wd)
    # Use the new names to rename the fasta
    rename_fasta(d_names, args.prefix, args.wd)

if __name__=="__main__":
    main()
     
