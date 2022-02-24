'''
Script para generar los tamaño de los subsets con los que se entrenará a 
AUGUSTUS
'''
import argparse
from ast import parse
from re import sub


def count_transcripts(f_in:str)->int:
    '''
    Función que permite contar el número de tránscritos de un gtf
    '''
    contador = 0
    with open (f_in, "r") as gtf:
        for linea in gtf:
            if linea.split()[2] == "transcript":
                contador += 1
    return contador

def subset_sizes(total: int)-> list:
    '''
    Función que determian el tamaño de los subsets en función del número de
    genes totales disponibles
    '''
    # Si hay menos de 1000 genes se cogen todos
    if total < 1000:
        subset = [total]
    
    # Si hay más de 1000 pero menos de 1500
    elif total > 1000 and total < 1500:
        subset = [200, 500, 800, 1000]
    
    # Si hay más de 1500 pero menos de 2000
    elif total > 1500 and total < 2000:
        subset = [200, 500, 800, 1000, 1500]
    
    # A partir de 2000 se inscrmenta de mil en mil hasta 8000
    elif total > 2000:
        subset = [200, 500, 800, 1000, 1500, 2000]
        while (subset[-1] + 1000) < total and (subset[-1] + 1000) <= 8000:
            subset.append(subset[-1] + 1000)
    return subset


def main():
    parser = argparse.ArgumentParser()
    #parser.add_argument("gtf")
    parser.add_argument("n", type=int)
    parser.add_argument("-ts", "--test_size",
                        help="size of the test set",
                        nargs='?', type=int, const=500, default=500)
    args = parser.parse_args()

    # Contar los tránscritos
    total_transcripts = args.n

    # Restar los tránscritos que se van a dedicar al testeo
    testing_transcripts = total_transcripts - args.test_size
    subsets = subset_sizes(testing_transcripts)
    # printear la lista sin corchete para utilizarla en el script de bash
    print(*subsets, sep=",")

if __name__=="__main__":
    main()
    