'''
Script para añadir lso nucleótidos correspondientes al codón de stop
a la CDS
'''

import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("gtf")
    args = parser.parse_args()
    f_out = open("modificado_" + args.gtf, "w")
    with open(args.gtf, "r") as f_in:
        # Leer la primera linea y parsear
        linea_aux  = f_in.readline() 
        ll_aux = linea_aux.split("\t")
        gene_id_aux = ll_aux[-1].split('"')[1]
        # Si es en la strand negativa el stop está al inicio
        if ll_aux[6] == "-":
            ll_aux[3] = str(int(ll_aux[3])-3)
        # Se sigue leyendo el fichero
        for linea in f_in: 
            ll = linea.split("\t")
            gene_id = ll[-1].split('"')[1]
            # Si el gen es el mismo que el antrior se escribe la anteior linea
            # y la nueva se almacena en aux
            if gene_id == gene_id_aux:
                definitive_line = "\t".join(ll_aux)
                f_out.write(definitive_line)
                ll_aux = ll
                gene_id_aux = gene_id
            # Si no es el mismo gen
            else:
                # Si el gen anterior estaba en la strand postitiva se añade el 
                # stop al último exon
                if ll_aux[6] == "+":
                    ll_aux[4] = str(int(ll_aux[4])+3)
                # Si el nuevo gen está en la strand - se extiende el codon de 
                # stop en el primer exon
                if ll[6] == "-":
                    ll[3] = str(int(ll[3])-3)
                definitive_line = "\t".join(ll_aux)
                f_out.write(definitive_line)
                ll_aux = ll
                gene_id_aux = gene_id
        # Ultima linea al salir del bucle
        if ll[6] == "+":
            ll[4] = str(int(ll[4])+3)
        definitive_line = "\t".join(ll)
        f_out.write(definitive_line)


if __name__=="__main__":
    main()
