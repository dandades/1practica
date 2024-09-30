#!/bin/bash

cut -d',' -f1-11,13-15 supervivents.csv > temp.csv
awk -F, '$14!="True"' temp.csv > temp2.csv
expr $(wc -l < temp.csv) - $(wc -l < temp2.csv)
