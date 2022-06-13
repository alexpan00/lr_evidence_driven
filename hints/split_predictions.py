'''
Script to split predicted genes using external evidence in two different files.
One file will contain those genes supported by external evidence and the other
file will contain the genes that are not supported by external evidence.
'''
import os
import argparse


class prediction():
    '''
    Class to storage the information of a predicted gene

    Attributes:
    ----------
    gtf (str): gene information in gtf format
    supported (bool): True if the gene is supported by external evodence, False
        if it is supported.

    Methods:
    --------
    __str__: convert prediction to a str
    add_feature: add a new gtf line to the prediction object
    '''
    def __init__(self,
                gtf = "",
                supported = False):
        self.gtf = gtf
        self.supported = supported
    

    def add_feature(self, feature: str)-> None:
        '''
        Method to add a new gtf line to the prediction object
        '''
        self.gtf += feature
    

    def __str__(self) -> str:
        '''
        Method to covert the prediction object to a str
        '''
        return self.gtf


def main():
    parser = argparse.ArgumentParser(description="Split the predicted genes by AUGUSTU using external evidence in two files, one with the supported genes and other with the not supported genes")
    parser.add_argument("gtf",
                        help="Path to the gtf file to be splited")
    args = parser.parse_args()
    # Get the base name and the path of the 
    name = os.path.basename(args.gtf)
    path = os.path.dirname(args.gtf)
    # Opend the gtf file with the predictions and create files for the outputs
    with open(args.gtf, "r") as f_in, \
        open(path + "/supported_" + name, "w") as supported, \
        open(path + "/non_supported_" + name, "w") as non_supported:
        for line  in f_in:
            # The start of a gene is preceded by a commented line satarting 
            # with "# start"
            if line.startswith("# start"):
                gene = prediction()
            # The gene information in gtf format is in the uncomented lines
            # This information is added to the prediction object
            if not line.startswith("#"):
                gene.add_feature(line)
            # The hint groups fully obeyed gives information about the number
            # of hints that suport a prediction. The number is at the end
            # of the line and if it is bigger than 0 it means that there
            # is at least one hint that support the prediction
            if line.startswith("# hint groups fully obeyed:"):
                n_hint = int(line.split()[-1])
                if n_hint > 0:
                    while not line.startswith("# incompatible"):
                        line = next(f_in)
                        evidence = line.split()[1]
                        if evidence != "RM":
                            gene.supported = True
            # The line "# end gene xx" marks the end of the gene. At this
            # the gene will be written to the file that it belong depending
            # on the supported atribute
            if line.startswith("# end gene"):
                if gene.supported:
                    supported.write(str(gene))
                else:
                    non_supported.write(str(gene))


if __name__ == "__main__":
    main() 

