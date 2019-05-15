#!bin/bash
#Menu
echo "Que quieres hacer:"
echo "1. Suma"
echo "2. Resta"
echo "3. Divideix"
echo "4. Multiplica"
read x

echo "Introduce el primer numero: "
read z
echo "introduce el segundo numero: "
read y

case $x in
	1) echo "$z + $y = $(( $z + $y ))";;
	2) echo "$z - $y = $(( $z - $y ))";;
	3) echo "$z / $y = $(( $z / $y ))";;
	4) echo "$z * $y = $(( $z * $y ))";;	
esac

	
