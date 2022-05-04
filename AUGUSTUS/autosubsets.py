'''
Script to calculate the size of the subsets that will be used to train 
AUGUSTUS
'''
import argparse


def count_transcripts(f_in:str)->int:
    '''
    Function to count the number of transcripts in a gtf file
    Input:
        f_in (str): path to the input gtf
    
    Output:
        count (int): number of transcripts in the gtf
    '''
    count = 0
    with open (f_in, "r") as gtf:
        for linea in gtf:
            if linea.split()[2] == "transcript":
                count += 1
    return count


def subset_sizes(total: int)-> list:
    '''
    Function to determinate the sizes of the subsets based on the total number
    of genes
    '''
    # If the number is smaller than 1000 oisck all of them
    if total < 1000:
        subset = [total]
    
    # if the total is between 1000 and 1500
    elif total > 1000 and total < 1500:
        subset = [200, 500, 800, 1000]
    
    # if the total is between 1500 and 2000
    elif total > 1500 and total < 2000:
        subset = [200, 500, 800, 1000, 1500]
    
    # From 2000 increase the number by 1000 to 8000
    elif total > 2000:
        subset = [200, 500, 800, 1000, 1500, 2000]
        while (subset[-1] + 1000) < total and (subset[-1] + 1000) <= 8000:
            subset.append(subset[-1] + 1000)
    return subset


def main():
    parser = argparse.ArgumentParser(description="Generate training subset sizes")
    #parser.add_argument("gtf")
    parser.add_argument("n", type=int,
                        help="Total number of transcripts")
    parser.add_argument("-ts", "--test_size",
                        help="size of the test set",
                        nargs='?', type=int, const=500, default=500)
    args = parser.parse_args()

    # Get the total number of transcripts
    total_transcripts = args.n

    # Substract the number of genes that will be dedicated to testeing
    testing_transcripts = total_transcripts - args.test_size
    subsets = subset_sizes(testing_transcripts)
    # print the list wo/ the brackets to be used in bash script
    print(*subsets, sep=",")

if __name__=="__main__":
    main() 