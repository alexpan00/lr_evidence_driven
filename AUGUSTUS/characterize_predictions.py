'''
Script to split the gtf corresponding to the predictions of a particular model
in 3 different gtf files for downstream anlysis. This scripts will contain the
perfecly predected genes, the FP predictions, those are the predictions that
do not overlap with any gene of the reference and finally the FN, that should
be taken directly from the reference.
'''

import os
import argparse

def parse_identity(identity_file: str)-> dict:
    '''
    Parse the identity file to generate a dictionary of sets. These sets will
    contain the perfect hits, the TP and the maching genes of the reference.

    Inputs:
        identi_file (str): path to the .identity file produce by the get_stats
        script
    
    Outputs:
        gene_dict (dict): a dictionary of sets
    '''
    # the identity file has 3 filds: the ref gene id, the predicted gene id
    # and the identity %
    ref_fild = 0
    prediction_fild = 1
    identity_fild = 2
    gene_dict = dict()
    gene_dict["PH"] = set()
    gene_dict["TP"] = set()
    gene_dict["ref"] = set()
    with open(identity_file, "r") as f_in:
        for line in f_in:
            ll = line.split()
            gene_dict["ref"].add(ll[ref_fild])
            gene_dict["TP"].add(ll[prediction_fild])
            # If thhe identity percentage is 100 it is a perfect prediction
            if ll[identity_fild] == "100.0":
                gene_dict["PH"].add(ll[prediction_fild])
    
    return gene_dict


def filter_prediction(gene_dict: dict, gtf_pre: str, wd: str, model: str):
    '''
    Function to filter a GTF file with predictions and split the genes
    in two different files, one file for perfect hits and other file for FP

    Inputs:
        gene_dict (dict): dictionary with the information of the PH and th TP
        gtf_pre (str): path to the gtf file with the predicted genes
        wd (str): path to write the output files
        model (str): name of the model
    '''
    feature_fild = 2
    info_fild = -1
    ph_gtf = os.path.join(wd, "PH_" + model + ".gtf")
    fp_gtf = os.path.join(wd, "FP_" + model + ".gtf")
    # Open the prediction gtf and two files for writing the PH and the FP
    with open(gtf_pre, "r") as f_in, open(ph_gtf, "w") as PH_out, open(fp_gtf, "w") as FP_out:
        for line in f_in:
            # Don't read the commented lines
            if not line.startswith("#"):
                ll = line.split("\t")
                # Ignore the lines with genes
                if ll[feature_fild] != "gene":
                    # if the line is a transcript the transcript id is in at the
                    # end of the line
                    if ll[feature_fild] == "transcript":
                        transcript_id = ll[info_fild].rstrip()
                        
                        if transcript_id in gene_dict["PH"]:
                            # Give the line the correct format before writing
                            gene_info = 'gene_id "%s"; transcript_id "%s";' % \
                                (transcript_id.split(".")[0], transcript_id)
                            ll[info_fild] = gene_info + "\n"
                            line = "\t". join(ll)
                            PH_out.write(line)
                        elif transcript_id not in gene_dict["TP"]:
                            gene_info = 'gene_id "%s"; transcript_id "%s";' % \
                                (transcript_id.split(".")[0], transcript_id)
                            ll[info_fild] = gene_info + "\n"
                            line = "\t". join(ll)
                            FP_out.write(line)
                    else:
                        # if it is not a transcript (CDS) the last
                        # part of the line needs to be parsed. The transcript
                        # id is after the first ". Also, it is necesary for
                        # SQANTI3 to parse the gtf to change de CDS for exon
                        if ll[feature_fild] == "CDS":
                            ll[feature_fild] = "exon" # change CDS for exon
                        transcript_id = ll[info_fild].split('"')[1]
                        if transcript_id in gene_dict["PH"]:
                            gene_info_list = ll[info_fild].split()
                            gene_info = gene_info_list[-2] + " " + gene_info_list[-1] + " " + gene_info_list[-4] + " " + gene_info_list[-3] + "\n"
                            line = "\t".join(ll[:8])
                            line += "\t" + gene_info
                            PH_out.write(line)
                        elif transcript_id not in gene_dict["TP"]:
                            gene_info_list = ll[info_fild].split()
                            gene_info = gene_info_list[-2] + " " + gene_info_list[-1] + " " + gene_info_list[-4] + " " + gene_info_list[-3] 
                            line = "\t".join(ll[:8])
                            line += "\t" + gene_info + "\n"
                            FP_out.write(line)
                

def filter_ref(found_genes: set, gtf_ref: str, wd: str, model: str):
    '''
    Function to filter the reference GTF file and select the genes
    that are not present in a set

    Inputs:
        found_genes (set): set with the found genes
        gtf_ref (str): path to the reference gtf
        wd (str): path to write the output files
        model (str): name of the model
    '''
    feature_fild = 2
    info_fild = -1
    fn_gtf = os.path.join(wd, "FN_" + model + ".gtf")
    # Open the ref gtf and a file to write the FN
    with open(gtf_ref, "r") as f_in, open(fn_gtf, "w") as FP_out:
        for line in f_in:
            ll = line.split("\t")
            transcript_id = ll[info_fild].split('"')[3]
            if transcript_id not in found_genes:
                ll[feature_fild] = "exon"
                line = "\t".join(line)
                FP_out.write(line)
        
def main():
    parser = argparse.ArgumentParser(description="Get 3 GTFs, one with the perfect predictions, one with the FP and one with the FN")
    parser.add_argument("wd", help="Path to the stats output")
    parser.add_argument("model_name", help="Name of the model")
    parser.add_argument("pre_GTF", help="GTF file with the predictions")
    parser.add_argument("ref_GTF", help="GTF used as reference to get the stats")
    args = parser.parse_args()

    # Generate 3 list of genes that will be used to filter the predictions GTF
    # and the reference GTF. These list contain the perfectly predicted genes,
    # the TP genes (prefect and non-perfect hits) and a 3rd list contains
    # the referencen predicted genes.
    identity_file = os.path.join(args.wd, args.model_name + ".identity")
    gene_dict = parse_identity(identity_file)

    # Filter the prediction file using the information in the gene_dict
    filter_prediction(gene_dict, args.pre_GTF, args.wd, args.model_name)

    # Filter the reference file to get the FN
    filter_ref(gene_dict["ref"], args.ref_GTF, args.wd, args.model_name)


if __name__ == "__main__":
    main()