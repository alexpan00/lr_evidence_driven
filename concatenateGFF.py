'''
Dado un fichero con los BUSCO complete genes que se quieren incorporar al 
gff final y un directorio crea un gff modificando los nombres de los genes 
para que sean más informativos 
'''

import argparse

def gene2list(gene_file: str)-> list:
    '''
    Función que le el fichero con genes y lo convierte en una lista
    '''
    l_genes = list()
    with open(gene_file, "r") as f_in:
        for linea in f_in:
            l_genes.append(linea.strip())
    return l_genes

def concatenar(l_genes, path):
    '''
    Función que lee los genes de la lista de genes, abre los gff, remplaza el
    nombre del gen y del tráncrito por el id en orthoDB y lo escribe en un
    fichero con el resto de genes
    '''
    anot_fild = 2
    # abrir el fichero de salida
    f_out = open("complete.gff", "w")
    # Leer cada gen de la lista
    for gen in l_genes:
        # Se abre el fichero del gen correspondiente
        with open(path + "/" + gen + ".gff", "r") as f_in:
            for line in f_in:
                line_l = line.split()
                if line_l[anot_fild] == "gene":
                    gen2replace = line_l[-1]
                    line = line.replace(gen2replace, gen)
                    f_out.write(line)
                elif line_l[anot_fild] == "transcript":
                    transcript2replace = line_l[-1]
                    line = line.replace(transcript2replace, gen + ".t1")
                    f_out.write(line)
                else:
                    line = line.replace(gen2replace, gen)
                    f_out.write(line)
    f_out.close()

           
def main():
    parser = argparse.ArgumentParser()
    # Archivo que contiene los genes completos no duplicados que se quieren concatenar
    parser.add_argument("genes")
    # Path a los archivos gff
    parser.add_argument("path")
    args = parser.parse_args()
    l_genes = gene2list(args.genes)
    concatenar(l_genes, args.path)

if __name__=="__main__":
    main()
