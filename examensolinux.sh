#!/bin/bash
x=0
while `test $x -ne 9` ; do
	clear
	#Menú
	echo "Menú d'accions per localitzar fitxers a partir de text"
	echo "======================================================"
	echo ""
	echo "1. Localitzar fitxer amb text..."
	echo "2. Canviar el nom al fitxer indicat"
	echo "3. Canviar d'ubicació"
	echo "9. Finalitzar"
	read x
	
	
	case $x in
		9)
			echo "Adeu!"
      			break
			;;
			
		1) 
			echo "Digues text"
			read nom	
			grep -rn `pwd` -e "$nom"
			read -n1 -r -p "Enter per continuar, si no mostra res, es que no hi ha res amb aquest text" key
			;;
		2)
			echo "Nom del fitxer"
			read nom
			echo "Nou nom"
			read nou_nom
			if [ ! -f "$nom" ]
			then
    				echo "$nom no existeix"
				read -n1 -r -p "Enter per continuar" key
			elif [ -f "$nou_nom" ]
			then
    				echo "$nou_nom ja existeix"
				read -n1 -r -p "Enter per continuar" key
			else
				mv $nom $nou_nom
				echo "Ara $nom es diu $nou_nom" 
				read -n1 -r -p "Enter per continuar" key
			fi		
			;;
		3) 
			
			echo "Escriure '..' vol dir anar al directori anterior"
			echo "Aquests son els directoris de la ruta: `ls -d */`"
			echo "Nom del directori."
			read nom
			if [ -d "$nom" ]
			then
				cd $nom
			else 
				echo "No existeix un directori nomenat $nom"
				
			fi
			echo "Ets a `pwd`"
			read -n1 -r -p "Enter per continuar" key
			;;			
	esac
done

