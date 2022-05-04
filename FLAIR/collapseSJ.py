'''
Script to collpase identical SJ between sampels found using STAR and get the
total number of supporting reads
'''
import os
import argparse


def main():
    parser = argparse.ArgumentParser(description="Get a summary of multiple SJ.out.tab files")
    parser.add_argument("SJ", help="path to the directory with the SJ.out.tab files")
    args = parser.parse_args()
    dir = os.path.dirname(args.SJ)
    SJ = os.path.basename(args.SJ)
    # Output file
    f_out = open(dir + "/collapsed_" + SJ, "w")
    # List to store the lines as they are read
    aux_record = list()
    with open(args.SJ, "r") as f_in:
        for line in f_in:
            record = line.split()
            # The coverage of the SJ is in the fild 6. Convert it to int 
            record[6] = int(record[6])
            if aux_record:
                # If the two SJ are the same sum the coverage
                if aux_record[1] == record[1] and aux_record[2] == record[2]:
                    aux_record[6] += record[6]
                # If the SJ are not the same write the first SJ and store
                # the new one
                else:
                    aux_record[6] = str(aux_record[6])
                    record_str = "\t".join(aux_record)
                    f_out.write(record_str + "\n")
                    aux_record = record
            else:
                aux_record = record
    # Write the last record
    aux_record[6] = str(aux_record[6])
    record_str = "\t".join(aux_record)
    f_out.write(record_str + "\n")
    f_out.close()

if __name__=="__main__":
    main()