#!/bin/bash

# PRÀCTICA 1: TRACTAMENT DE DADES AMB SHELL SCRIPT
# GRUP 1, PLAB 811

# ------------------------------------------------------------------------------------------------------------------------------
# Pas 5: En cas d'adjuntar un paràmetre coincident amb títol o identificador, imprimeix unes columnes rellevants pels casos de coincidència.
# ------------------------------------------------------------------------------------------------------------------------------

# Estructura condicional: Comprovem si s'ha adjuntat un argument amb l execució del programa, -n $1.
# Si resulta en fals, s executa la resta de passos del programa.
if [ -n "$1" ]; then

	# Establim la variable $search i li conferim el valor de l'argument adjuntat.
	search=$1

	# Estructura condicional: Comprovem l'existència de l arxiu sortida.csv i si és de tipus file, -f sortida.csv.
	if [ -f "sortida.csv" ]; then

		# Establim la variable $cerca_espec perquè la cerca, grep, només s efectuï quan $search coincideix amb el títol o identificador, és a dir, columna $1 o $3.
		# Utilitzem la comanda cut per distingir camps, -d, i seleccionar, -f, les columnes desitjades de sortida.csv i, seguidament, canalitzar, |, per cercar el paràmetre adjuntat, $search, amb grep.
		cerca_espec=`cut -d',' -f1,3 sortida.csv | grep -i "$search"`

		# Establim la variable $cerca amb la coincidència sencera pel valor adjuntat a $search.
		# En el context de grep, -i significa que els resultats no siguin sensibles a majúscules o minúscules.
		cerca=`grep -i "$search" sortida.csv`

		# Estructura condicional: Si $cerca_espec no és buida, és a dir, s'han trobat coincidències per $search en títol o identificador per sortida.csv, retorna true; si no, retorna fals.
		# Si la condició es compleix, s'executarà la mostra de resultats. Si no ho és, és mostrarà el missatge corresponent.
		if [ -n "$cerca_espec" ]; then

			# Imprimeix missatge informatiu pel cas positiu de cerca.
	    		echo "Resultats de la cerca per a '$search':"
			# Imprimim la coicidència total, $cerca, distingim els camps, -d,i mostrem les columnes d'interès, -f..., amb la comanda cut.
	        	echo "$cerca" | cut -d',' -f1,2,6,7,8,17,18,19

		else
	      		# Imprimeix missatge informatiu donat que $cerca és buida, és a dir, no hi ha coincidències.
			echo "No s'han trobat coincidències per a '$search'."
		fi
		# Sortim del programa, un cop finalitzada la cerca.
		# Evitem el processament de la resta de passos.
		exit 0

	else
		# Pel cas d'inexistència de l arxiu sortida.csv, informa l usuari amb el següent missatge.
		echo "No existeix l'arxiu sortida.csv"
	fi

	# Sortim del programa, un cop determinat que no existeix sortida.csv.
	# Evitem el processament de la resta de passos.
	exit 0
fi


# ------------------------------------------------------------------------------------------------------------------------------
# Pas 1: Eliminem les columnes description i thumbnail_link
# ------------------------------------------------------------------------------------------------------------------------------

# Amb cut, establim la separació de camps, -d, seleccionem les columnes que són d'interès, -f, i les afegim a un nou arxiu temporal temp.csv, >.
# D'aquesta manera esborrem les columnes que no ens interessen

cut -d',' -f1-11,13-15 supervivents.csv > temp.csv


# ------------------------------------------------------------------------------------------------------------------------------
# Pas 2: Eliminem els registres que corresponen al valor True en la columna video_error_or_removed utilitzant awk
# ------------------------------------------------------------------------------------------------------------------------------

# Definim la separació de camps amb -F',' i copiem els registres on la columna triada, $14, no és True, != True, a un nou arxiu temp2.csv.
awk -F',' '$14!="True"' temp.csv > temp2.csv

# Definim una nova variable dif que recull l'expressió, expr, de la diferència entre el nombre de registres de l arxiu anterior, temp.csv, i el de nova creació, temp2.csv.
# Pel cas -l, la comanda wc recull el nombre de registres per l arxiu d interès, < <arxiu>. 
dif=$(expr $(wc -l < temp.csv) - $(wc -l < temp2.csv))

# Imprimim la variable $a amb un missatge de notificació.
echo "S'han eliminat $dif registres"


# ------------------------------------------------------------------------------------------------------------------------------
# Pas 3: Creem una nova columna Ranking_views i definim el valors per a cada registre segons les visualitzacions que corresponen. Tot en awk
# ------------------------------------------------------------------------------------------------------------------------------

# Definim la separació de camps per , amb -F i pel primer registre (NR==1) imprimim l'encapçalament precedit del contingut anterior: $0 i ,Ranking_views.
awk -F',' 'NR==1 {
    print $0 ",Ranking_views";
    next
}
{

	# Establim una estructura condicional d awk que pren el valor de les visualitzacions, $8, i les classifica per tres calaixos.
	if ($8 >= 1000000) Ranking_views="Estrella";
	else if ($8 >= 100000) Ranking_views="Excel.lent";
	else Ranking_views="Bo";
	# Imprimim el contingut prexistent i afegim el valor calculat per a cada fila, separat d una coma per detectar-lo com a nova columna.
	print $0 "," Ranking_views

# Tanquem les accions d awk i establim l arxiu d entrada, temp2.csv, i el de sortida, temp3.csv, de nova creació.
}' temp2.csv > temp3.csv


# ------------------------------------------------------------------------------------------------------------------------------
# Pas 4: Creem dues columnes noves, rlikes i rdislikes, i, amb estructura while, prenem valors de camps existents per a cada registre.
# ------------------------------------------------------------------------------------------------------------------------------

# Definim la variable encap a true per distingir el primer registre i tractar-lo com encapçalament.
encap=true

# Establim l estructura while i la fem llegir cada registre de l arxiu d entrada, read -r line.
# Amb -r en aquest context, establim els caràcters d'escapament que puguem trobar, \, com caràcters normals. Evitem un salt de línia indesitjat.
while read -r line; do

	# Estructura condicional: tractem la primera línia de l'arxiu com encapçalament.
	if $encap; then
		# Imprimim l encapçalament actual, $line, i li afegim els títols rlikes i rdislikes amb comanda echo.
		# La sortida de la comanda arriba a sortida.csv, que creem a partir d aquest punt com a arxiu final del shell script.
		echo "$line,rlikes,rdislikes" > sortida.csv
		# Establim la variable encap a false perquè s executi el programa de l else a partir de la segona línia.
		encap=false

	# A partir de la segona línia i fins al final de l'arxiu, per a cada registre, respon al següent programa.
	else
		# Establim variables $views, $likes i $dislikes i les adjudiquem el seu valor per a cada registre.
		# La comanda echo imprimeix el registre sencer, $line, i amb el pipe, |, segueix la comanda cut, que separa camps per comes amb -d i defineix la columna, -f, que correspon.
		views=$(echo "$line" | cut -d',' -f8)
		likes=$(echo "$line" | cut -d',' -f9)
		dislikes=$(echo "$line" | cut -d',' -f10)

		# Estructura condicional: evitem la divisió per zero.
		# Si el valor de la variable $views és 0, establim directament el valor de rlikes i rdislikes en zero.
		if [[ "$views" -eq 0 ]]; then
			rlikes=0
			rdislikes=0

		# Pel cas general, seguim el següent programa.
		# En aquest context, bc és un mòdul descarregable que ens permet obtenir valors reals del resultat d una divisó en bash.
		# Establim la precisió en dues posicions decimals, scale=2 dins de l'echo, i canalitzem, |, a la comanda bc.
		else
			# Establim el valor de la columna rlikes com el resultat del valor de $likes per 100, entre el valor de $views.
			rlikes=$(echo "scale=2; ($likes*100) / $views" | bc)

			# Anàlogament, el valor de la columna rdislikes és el resultat del valor de $dislikes per 100, entre el valor de $views.
			rdislikes=$(echo "scale=2; ($dislikes*100) / $views" | bc)
		fi

		# Imprimim, echo, el registre prexistent, $line, i hi afegim les noves columnes junt amb els seus valors corresponents, $rlikes i $rdislikes.
		# Introduïm la impresió al final de l arxiu final, >>> sortida.csv.
		echo "$line,$rlikes,$rdislikes" >> sortida.csv
	fi

# Establim l'arxiu d entrada per a l execució de la lectura de cada registre per l estructura while, temp3.csv.
done < temp3.csv
