'''
Script to rename reads in sam file
'''

import os
import argparse

def main():
    parser = argparse.ArgumentParser(description="Rename reads in sam file")
    parser.add_argument("wd", help="Path to save the output")
    parser.add_argument("sam_file", help="path to the sam file")
    args = parser.parse_args()

    read_name = 0 # the read name is in the fist fild of the line
    new_sam = os.path.join(args.wd, "renamed_" + args.sam_file)

    with open(args.sam_file, "r") as f_in, open(new_sam, "w") as f_out:
        next(f_in)
        for i, line in enumerate(f_in):
            ll = line.split("\t")
            ll[read_name] = "ONT" + str(i)
            line = "\t".join(ll)
            f_out.write(line)

if __name__=="__main__":
    main()