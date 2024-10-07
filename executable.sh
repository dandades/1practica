#!/bin/bash

# Pas 1
cut -d',' -f1-11,13-15 supervivents.csv > temp.csv

# Pas 2
awk -F, '$14!="True"' temp.csv > temp2.csv
a=$(expr $(wc -l < temp.csv) - $(wc -l < temp2.csv))
echo "S'han eliminat $a registres"

# Pas 3
awk -F"," 'NR==1 {
	print $0 ",Ranking_views";
	next
}
{
	if ($8>=10000000) Ranking_views="Estrella";
	else if ($8>=1000000) Ranking_views="Excel·lent";
	else Ranking_views="Bo";
	print $0 "," Ranking_views
}' temp2.csv > temp3.csv

# Pas 4
