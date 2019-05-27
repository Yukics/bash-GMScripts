#!bin/bash
eleccion=0
while [ $eleccion -ne 9 ]
do
	echo "_____________________________________________" 
	echo "Que vols fer?"
	echo "1. Mostra els directoris"
	echo "2. Crea estructura per nou modul"
	echo "3. Pasa estructura d'un nou modul a Historic"
	echo "4. Elimina l'estructura d'un nou modul"
	echo "9. Sortir"	
	read eleccion
	echo "_____________________________________________"
	if [ $eleccion -eq 9 ]; then
      		break
  	fi
	case $eleccion in
		1) ls;;
		2) echo "Nom del nou modul" 
		read nommodul
		mkdir $nommodul
		cd $nommodul
		mkdir "Apunts" "Exercisis" "Documents"
		cd ..
		;;
		3)echo "Nom del modul a moure"
		read nommodul
		if [ ! -d "Historic" ]; then
 			mkdir "Historic"
		fi
		mv $nommodul "Historic"		
		;;
		4) echo "Nom del modul a esborrar"
		read nommodul
		rm -r $nommodul 
		;;			
	esac
done
