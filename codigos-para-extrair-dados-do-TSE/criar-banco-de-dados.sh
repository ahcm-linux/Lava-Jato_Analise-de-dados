#!/bin/bash

PATTERN_1='bem_candidato\|votacao_candidato_munzona\|receitas_candidatos_201*\|receitas_orgaos_partidarios_201*\|consulta_cand'
PATTERN_2='leiame_receitas-candidatos.pdf\|leiame_receitas-orgaos-partidarios.pdf\|leiame.pdf'

TMP=tmp_data
DB=$1
LINKS=$2

README=$(echo $DB | cut -d '.' -f 1)_readme-files
URLS=($(sed '/^[[:space:]]*$/d' $LINKS))

mkdir ./$TMP
mkdir ./$README

if [ ! -f $DB ]
then
	for url in "${URLS[@]}"
	do
		TABLE=$(echo $url | rev | cut -d '.' -f 2 | cut -d '/' -f 1 | rev)

		echo "(downloading files from $TABLE ...)"
		curl -o ./$TMP.zip $url
		echo "(unziping files ...)"
		unzip -q ./$TMP.zip -d ./$TMP

		FILES=$(ls -A ./$TMP | grep $PATTERN_1 | grep -v BRASIL | grep -v _BR | grep .csv)
		if [ ! -z "${FILES}" ]
		then
			echo "(populating database ...)"
			COUNTER=0
			for csv in $FILES
			do
				CSV_UTF8=$(echo $csv | cut -d '.' -f 1)_utf8.csv
				iconv -f ISO-8859-1 -t UTF-8 < ./$TMP/$csv > ./$TMP/$CSV_UTF8

				if [ "$COUNTER" == 0 ]
				then
					sqlite3 -separator ';' ./$DB ".import ./$TMP/$CSV_UTF8 $TABLE"
				else
					sqlite3 -separator ';' ./$DB ".import --skip 1 ./$TMP/$CSV_UTF8 $TABLE"
				fi

				COUNTER=`expr $COUNTER + 1`
			done
		else
			echo "no .csv files found for $TABLE"
		fi

		echo "($COUNTER .csv files were imported to database)"

        if [ "$COUNTER" -gt 0 ]
        then
		    echo "(saving readme files ...)"
		    PDF=$(ls -A ./$TMP | grep $PATTERN_2)
		    mv ./$TMP/$PDF ./$README/$TABLE-$PDF
		fi
		
		rm ./$TMP.zip
		rm ./$TMP/*

		echo ""
	done
else
	echo "(process ended without modifying database $DB)"
fi

echo "(removing temporary folder $TMP ...)"
rm -r ./$TMP

echo "(modifying $DB ...)"
sqlite3 ./$DB < ./modificar-banco-de-dados.sql

echo "(process has finished!)"
