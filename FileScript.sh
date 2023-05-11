#!/bin/bash

function znajdz(){
    find $(pwd) -maxdepth 1 -name "$1" -print
}

while getopts "c:f:m:r:p:o:z:u:d:" opt; do
    case ${opt} in
	c )
	  set -f
 	  IFS=','
	  TABLICA=($OPTARG)
	  PLIK=${TABLICA[0]}
	  SCIEZKA=$(pwd)
	  SCIEZKA+="/$PLIK"
	  if  [[ ${#TABLICA[@]} -eq 1 ]]; then
	    if test -f "$SCIEZKA"; then
		cat $SCIEZKA > kopia.txt
	    else
	        echo "Podany plik nie istnieje"
	    fi
	  else
	    DRUGASCIEZKA=${TABLICA[1]}
	    if test -f "$SCIEZKA" && [ -d "$DRUGASCIEZKA" ]; then
	    	DRUGASCIEZKA+="/kopia.txt"
		cat $SCIEZKA > $DRUGASCIEZKA
	    else
		[ -d "$DRUGASCIEZKA" ]
		echo "$DRUGASCIEZKA"
		echo "Podany plik lub sciezka docelowa nie istnieje"
	    fi
       	  fi
	  ;;
    f )
      NAZWA=$OPTARG
      touch $NAZWA
      ;;
    m )
      set -f
      IFS=','
      TABLICA=($OPTARG)
      #SCJ-SCIEZKA JEDEN
      #SCD-SCIEZKA DWA
      SCJ=${TABLICA[0]}
      SCD=${TABLICA[1]}
      if [[ ${SCJ:0:1} == '~' ]]; then
	 DLPLIKU=${#TABLICA[0]}
	 DLPLIKU=$((DLPLIKU-1))
	 SCJ="/home/$(whoami)/${SCJ:2:DLPLIKU-1}"
      fi
      if [[ ${SCJ:0:1} != '/' ]]; then
	 DLPLIKU=${#TABLICA[0]}
	 DLPLIKU=$((DLPLIKU-1))
	 SCIEZKA=$(pwd)
	 SCIEZKA+='/'
	 SCIEZKA+=$SCJ
	 SCJ=$SCIEZKA
      fi
      if [[ ${SCD:0:1} == '~' ]]; then
         DLPLIKU=${#TABLICA[1]}
	 DLPLIKU=$((DLPLIKU-1))
	 if [[ ${SCD:DLPLIKU:1} != '/' ]]; then
	    SCD+='/'
	 fi
	 SCD="/home/$(whoami)/${SCD:2:DLPLIKU-1}"
      fi
      if [[ ${SCD:0:1} != '/' ]]; then
         DLPLIKU=${#TABLICA[1]}
	 DLPLIKU=$((DLPLIKU-1))
	 if [[ ${SCD:DLPLIKU:1} != '/' ]]; then
	    SCD+='/'
	 fi
	 SCD="/home/$(whoami)/${SCD:0:DLPLIKU+1}"
	 echo "$SCD"
      fi
      if test -f "$SCJ" && [ -d "$SCD" ] && [[ "$SCD" != $(pwd) ]]; then
	mv $SCJ $SCD
      elif [[ "$SCD" == $(pwd) ]]; then
	echo "Pliku z aktualnego katalogu nie wolno kopiowac do aktualnego katalogu"
      elif [ ! -d "$SCD" ]; then
	echo "Katalog nie istnieje"
      elif test ! -f "$SCJ"; then
	echo "Plik nie istnieje"
      fi
      ;;
    r )
      SCIEZKA=$OPTARG
      if [[ $SCIEZKA != "all" ]] && [[ ${SCIEZKA:0:1} != "/" ]] && 
	 [[ ${SCIEZKA:0:1} != "~" ]]; then
	 DOPISANKA=$(pwd)
	 DOPISANKA+="/$SCIEZKA"
	 SCIEZKA=$DOPISANKA
      fi
      WARUNEK=$(grep -E "^/home/$(whoami)/.+|^~/.+" <<< $SCIEZKA )
      if test -f "$SCIEZKA" && [ -z "$WARUNEK" ]; then
         echo "Plik znajduje sie poza katalogiem uzytkownika"
      elif test -f "$SCIEZKA" && [ -n "$WARUNEK" ]; then
	 rm -v $SCIEZKA
      elif [[ $SCIEZKA == "all" ]]; then
	 SCIEZKA=$(pwd)
	 SCIEZKA+="/*"
	 WARUNEK=$(grep -E "^/home/$(whoami)/.+|^~/.+" <<< $SCIEZKA)
	 if [ -n "$WARUNEK" ]; then
	    rm -v $SCIEZKA
	 else
	    echo "Obecny katalog jest poza dostepem"
	 fi 
      else
	 echo "Podany plik nie istnieje lub zle wpisano all"
      fi
      ;;
    p )
      set -f
      IFS=','
      TABLICA=($OPTARG)
      OPCJA=${TABLICA[0]}
      if [[ $OPCJA == "alpha" ]]; then
	 ls -1
      fi
      if [[ $OPCJA == "g" ]]; then
	 LICZBA=${TABLICA[1]}
	 ROZMIAR="+$LICZBA"
	 find $(pwd) -maxdepth 1 -type f -or -type d -size $ROZMIAR 
      fi
      if [[ $OPCJA == "l" ]]; then
	 LICZBA=${TABLICA[1]}
	 ROZMIAR="-$LICZBA"
	 find $(pwd) -maxdepth 1 -type f -or -type d -size $ROZMIAR
      fi
      if [[ $OPCJA == "b" ]]; then
	 NAPIS=${TABLICA[1]}
	 ROZMIAR+="$NAPIS"
	 ROZMIAR+="*"
	 znajdz $ROZMIAR
      fi
      if [[ $OPCJA == "c" ]]; then
	 NAPIS=${TABLICA[1]}
	 ROZMIAR="*"
	 ROZMIAR+="$NAPIS"
	 ROZMIAR+="*"
	 znajdz $ROZMIAR
      fi
      if [[ $OPCJA == "e" ]]; then
	 NAPIS=${TABLICA[1]}
	 ROZMIAR="*"
	 ROZMIAR+="$NAPIS"
	 znajdz $ROZMIAR
      fi
      ;;
    o )
      set -f
      IFS=','
      TABLICA=($OPTARG)
      OPCJA=${TABLICA[0]}
      if [[ $OPCJA == "b" ]]; then
	 REGEKS="^${TABLICA[2]}"
      fi
      if [[ $OPCJA == "c" ]]; then
	 REGEKS="${TABLICA[2]}"
      fi
      if [[ $OPCJA == "e" ]]; then
	 REGEKS="${TABLICA[2]}$"
      fi
      cat ${TABLICA[1]} | grep -E $REGEKS
      ;;
    z )
      if [ ! -d $OPTARG ]; then
         echo "Nie znaleziono katalogu"
      else
	    zip -r spakowanepliki.zip $OPTARG 
      fi 
      ;;
    u )
      if [ ! -d $OPTARG ]; then
         echo "Nie odnalezniono katalogu"
      else
	    unzip spakowanepliki.zip -d $OPTARG 
      fi
      ;;
    d)
      set -f
      IFS=','
      TABLICA=($OPTARG)
      if [[ ${TABLICA[0]} == 'd' ]]; then
         SCIEZKA=${TABLICA[1]}
	 PELNASC="LOREMIPSUM"
         if [[ ${SCIEZKA[0]} != '/' ]] && [[ ${SCIEZKA[0]} != '~' ]];
	 then
	    PELNASC=$(pwd)
	    PELNASC+="/$SCIEZKA"
	 else
	    PELNASC=$TABLICA
	 fi
	 WARUNEK=$(grep -E "^/home/$(whoami)/.+|^~/.+" <<< $PELNASC)
	 if [ ! -d $PELNASC ]; then
	    echo "Podany katalog nie istnieje"
	 else
	    if [ -n WARUNEK ]; then
	       rm -rf $PELNASC
	    else
	       echo "Podana sciezka jest niedozwolona"
	    fi 
	 fi 
      fi
      if [[ ${TABLICA[0]} == 'm' ]]; then
	 NAZWA=${TABLICA[1]}
	 mkdir $NAZWA
      fi
      if [[ ${TABLICA[0]} == 'mv' ]]; then
	 NAZWA=${TABLICA[1]}
	 MIEJSCEDOC=${TABLICA[2]}
	 mv -v $NAZWA $MIEJSCEDOC
      fi
      if [[ ${TABLICA[0]} == 'c' ]]; then
	 cp -R ${TABLICA[1]} "${TABLICA[2]}/"
      fi
      ;;
    esac
done
shift $((OPTIND -1))
