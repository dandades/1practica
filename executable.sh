#!/bin/bash

# PRÀCTICA 1: TRACTAMENT DE DADES AMB SHELL SCRIPT
# GRUP 1, PLAB 811

# ------------------------------------------------------------------------------------------------------------------------------
# Pas 5:


if [ -n "$1" ]; then

	search=$1

	if [ -f "sortida.csv" ]; then

		cerca=`grep -i "$search" sortida.csv`

		if echo "$cerca" > /dev/null; then
	    		echo "Resultats de la cerca per a '$search':"
	        	echo "$cerca" | cut -d',' -f1,2,6,7,8,17,18,19
		else
	      		echo "No s'han trobat coincidències per a '$search'."
		fi
		exit 0

	else
		echo "No existeix l'arxiu sortida.csv"
	fi
	exit 0
fi

# ------------------------------------------------------------------------------------------------------------------------------
# Pas 1: Eliminar columnes description i thumbnail_link

# Amb cut seleccionem les columnes que són d'interès i les afegim a un nou arxiu temporal temp.csv.
# D'aquesta manera esborrem les columnes que no ens interessen

cut -d',' -f1-11,13-15 supervivents.csv > temp.csv


# Pas 2: Eliminar registres que corresponen al valor True en la columna video_error_or_removed utilitzant awk

# Definim la separació de camps amb -F',', i els registres on la columna triada no és True els copiem a un nou arxiu temp2.csv
awk -F',' '$14!="True"' temp.csv > temp2.csv

# Definim una nova variable a que recull l'expressió de la diferència entre el nombre de registres de l arxiu anterior (temp.csv) i el de nova creació (temp2.csv)
a=$(expr $(wc -l < temp.csv) - $(wc -l < temp2.csv))
# Imprimim la variable a amb un missatge de notificació.
echo "S'han eliminat $a registres"

# ------------------------------------------------------------------------------------------------------------------------------
# Pas 3: Creem una nova columna Ranking_views i definim el valors per a cada registre segons les visualitzacions que corresponen. Tot en awk
# Definim la separació de camps per , i pel primer registre (NR==1) imprimim l'encapçalament ,Ranking_views.
awk -F',' 'NR==1 {
    print $0 ",Ranking_views";
    next
}
{
# Establim una estructura condicional d awk que pren el valor de les visualitzacions i les classifica per tres calaixos
    if ($8 >= 1000000) Ranking_views="Estrella";
    else if ($8 >= 100000) Ranking_views="Excel.lent";
    else Ranking_views="Bo";
    print $0 "," Ranking_views
# Tanquem les accions d awk i establim l arxiu d entrada temp2.csv i el de sortida temp3.csv, de nova creació
}' temp2.csv > temp3.csv

# ------------------------------------------------------------------------------------------------------------------------------
# Pas 4:
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
