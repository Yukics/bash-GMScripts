#!bin/bash
echo -n "Escriu un nom: "
read x 
if [ -d "$x" ];then
	echo "Es una carpeta"
elif [ -f "$x" ];then
	echo "Es un fitxer"
else
	echo "No existeix"
fi
