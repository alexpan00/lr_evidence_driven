'''
Script para generar una serie de subsets de tamaño especificado por el 
usuario a partir de un fichero genebank

El subset de tamaño más grande será igual al de tamaño más pequeño más un 
número de genes (Los subsets pequeños son subsets de los grandes)
'''

import random
import argparse


class gene:
    '''
    Clase para almacenar la infroamción de genes en formato GeneBank
    '''
    def __init__(self, locus, features, base_count, origin) -> None:
        self.locus = locus
        self.features = features
        self.base_count = base_count
        self.origin = origin
    def __str__(self) -> str:
        return self.locus + self.features + self.base_count + self.origin
    def get_gene_id(self)-> str:
        gene_line = self.features.split("\n")[-2]
        gene_id = gene_line.lstrip(' /gene="')
        gene_id = gene_id.rstrip('.t1"')
        return gene_id

def parse_gb(f_in: str)-> list:
    '''
    Lee el gb completo y convierte los genes a la clase gen. Almacena los 
    genes en una lista.
    '''
    # Lista de campos de una entrada en formato gb
    l_campos = []
    # Lista de genes
    l_gb = []
    # Campo del archivo gb que se está leyendo
    indice = 0
    with open(f_in, "r") as gb_file:
        for linea in gb_file:
            # LOCUS es el primer campo. Si ya había una entrada se pasa de la 
            # lista a la clase gen y se vacía la lista
            if linea.startswith("LOCUS"):

                if l_campos:    
                    gene_aux = gene(l_campos[0], l_campos[1], l_campos[2], l_campos[3])
                    l_gb.append(gene_aux)
                    l_campos = list()
                    indice = 0

                if not l_campos:
                    l_campos =["","","",""]
                    l_campos[indice] += linea
            # Al leer features se cambia el indice a 1
            elif linea.startswith("FEATURES"):
                indice = 1
                l_campos[indice] += linea
            # Al leer BASE se cambia el indice a 2
            elif linea.startswith("BASE"):
                indice = 2
                l_campos[indice] += linea
            # Al leer ORIGIN se cambia el indice a 3
            elif linea.startswith("ORIGIN"):
                indice = 3
                l_campos[indice] += linea
            # Las lineas que no empiezan por ninguna de las anteriores se
            # guardan en la posición de la lista correspondiente al indice
            # que estuviera definido previamente
            else:
                l_campos[indice] += linea

        # Hay que guardar el último gen al salir del bucle
        gene_aux = gene(l_campos[0], l_campos[1], l_campos[2], l_campos[3])
        l_gb.append(gene_aux)

        return l_gb

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("genebank")
    parser.add_argument("out_name")
    parser.add_argument("out_dir")
    parser.add_argument('-l', '--list', help='delimited list input', type=str)
    parser.add_argument("--seed", help="seed", nargs='?', type=int, const=123, default=123)

    args = parser.parse_args()
    # Generar una lista con los genes
    l_gb = parse_gb(args.genebank)
    # Generar una lista aleatoria con los núemros de los genes que 
    # se incluirán en el test
    random.seed(args.seed)
    n_genes = [int(item) for item in args.list.split(',')]

    # Generar una lista random para samplear los genes
    randomlist = random.sample(range(0, n_genes[-1]), n_genes[-1])
    for i in n_genes:
        with open(args.out_dir \
                  + "/results/subset_" \
                  + str(i) \
                  + "_" + args.out_name \
                  + ".gb", "w") as f_out:
            for j in range(i):
                f_out.write(str(l_gb[randomlist[j]]))
            
if __name__=="__main__":
    main()

