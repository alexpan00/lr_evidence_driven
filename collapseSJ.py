'''
Script que permite colapsar las SJ identicas encontradas en diversas muestras
y sumar los conteos
'''
import os
import argparse

from numpy import record

def main():
    parser = argparse.ArgumentParser()
    # SJ.out.tab de todas las muestras
    parser.add_argument("SJ")
    args = parser.parse_args()
    directorio = os.path.dirname(args.SJ)
    archivo = os.path.basename(args.SJ)
    # Archvio de salida
    f_out = open(directorio + "/collapsed_" + archivo, "w")
    print(directorio + "/collapsed_" + archivo)
    # Variable en la que se irán guardando las lineas a media que se lean
    aux_record = list()
    with open(args.SJ, "r") as f_in:
        for linea in f_in:
            record = linea.split()
            # Como se quiere sumar la covertura, columna 6, es necesario 
            # convertir el str a int
            record[6] = int(record[6])
            if aux_record:
                # En caso de que las dos SJ sean iguales se suma su cobertura
                if aux_record[1] == record[1] and aux_record[2] == record[2]:
                    aux_record[6] += record[6]
                # Si son dintas se escribe el record_aux y se actualiza con
                # el nuevo
                else:
                    aux_record[6] = str(aux_record[6])
                    record_str = "\t".join(aux_record)
                    f_out.write(record_str + "\n")
                    aux_record = record
            else:
                aux_record = record
    # Al salir del bucle hay que guardar el último record
    aux_record[6] = str(aux_record[6])
    record_str = "\t".join(aux_record)
    f_out.write(record_str + "\n")
    f_out.close()

if __name__=="__main__":
    main()
