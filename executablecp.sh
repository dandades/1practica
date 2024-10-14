#!/bin/bash

# Pas 5:
if [ -n "$1" ]; then
    search=$1
    # Cerca el terme de cerca al fitxer sortida.csv
    if grep -i "$search" sortida.csv > /dev/null; then
        echo "Resultats de la cerca per a '$search':"
        grep -i "$search" sortida.csv | cut -d',' -f1,2,6,7,8,17,18,19
    else
        echo "No s'han trobat coincidències per a '$search'."
    fi
    exit 0
fi


# Pas 1: Extraer columnas seleccionadas del archivo CSV inicial
cut -d',' -f1-11,13-15 supervivents.csv > temp.csv

# Pas 2: Filtrar registros con la columna 11 igual a "True"
awk -F',' '$14!="True"' temp.csv > temp2.csv
a=$(expr $(wc -l < temp.csv) - $(wc -l < temp2.csv))
echo "S'han eliminat $a registres"

# Pas 3: Clasificar según el número de visualitzacions
awk -F',' 'NR==1 {
    print $0 ",Ranking_views";
    next
}
{
    if ($8 >= 1000000) Ranking_views="Estrella";
    else if ($8 >= 100000) Ranking_views="Excel.lent";
    else Ranking_views="Bo";
    print $0 "," Ranking_views
}' temp2.csv > temp3.csv

# Pas 4: Càlcul del percentatge de likes i dislikes
encap=true

while read -r line; do

	if $encap; then
		echo "$line,rlikes,rdislikes" > sortida.csv
		encap=false

	else
		views=$(echo "$line" | cut -d',' -f8)
		likes=$(echo "$line" | cut -d',' -f9)
		dislikes=$(echo "$line" | cut -d',' -f10)

		if [[ "$views" -eq 0 ]]; then
			rlikes=0
			rdislikes=0
		else
			rlikes=$(echo "scale=2; ($likes*100) / $views" | bc)
			rdislikes=$(echo "scale=2; ($dislikes*100) / $views" | bc)
		fi

		echo "$line,$rlikes,$rdislikes" >> sortida.csv
	fi

done < temp3.csv
