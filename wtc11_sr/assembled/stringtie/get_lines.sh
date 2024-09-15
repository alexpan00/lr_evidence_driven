#!/bin/bash

#Script to obtain only the stranded isoforms

fichero_in=$1
fichero_out=$2

while read -r line ; do
 if [[ "$line" =~ ^#.* ]] ; then
  echo "$line"
 else
   strand=$(echo $line | awk '{print $7}')
   if [[ "$strand" == "+" ]]; then
    echo "$line"
   elif [[ "$strand" == "-" ]]; then
    echo "$line"
   else
    continue
   fi
 fi
done < "$fichero_in">"$fichero_out"
