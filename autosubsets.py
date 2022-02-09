'''
Script para generar los tamaño de los subsets con los que se entrenará a 
AUGUSTUS
'''
import argparse
from ast import parse
from re import sub

def count_transcripts(f_in:str)->int:
    contador = 0
    with open (f_in, "r") as gtf:
        for linea in gtf:
            if linea.split()[2] == "transcript":
                contador += 1
    return contador

def subset_sizes(total: int)-> list:
    if total < 1000:
        subset = [total]
    elif total > 1000 and total < 1500:
        subset = [200, 500, 800, 1000]
    elif total > 1500 and total < 2000:
        subset = [200, 500, 800, 1000, 1500]
    elif total > 2000:
        subset = [200, 500, 800, 1000, 1500, 2000]
        while (subset[-1] + 1000) < total:
            subset.append(subset[-1] + 1000)
    return subset


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("gtf")
    parser.add_argument("-ts", "--test_size",
                        help="size of the test set",
                        nargs='?', type=int, const=500, default=500)
    args = parser.parse_args()
    total_transcripts = count_transcripts(args.gtf)
    testing_transcripts = total_transcripts - args.test_size
    subsets = subset_sizes(testing_transcripts)
    print(*subsets, sep=",")

if __name__=="__main__":
    main()
    