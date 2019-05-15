#!bin/bash
#Menu
echo "Que quieres hacer:"
echo "1. Suma"
echo "2. Resta"
echo "3. Divideix"
echo "4. Multiplica"
read x

if [ $x -eq "1" ];then
	echo "Introduce el primer numero: "
	read y
	echo "introduce el segundo numero: "
	read z
	ans=$(( $z + $y ))
	echo "$z + $y = $ans"

elif [ $x -eq "2" ];then
	echo "Introduce el primer numero: "
	read y
	echo "introduce el segundo numero: "
	read z
	ans=$(( $y -$z ))
	echo "$y - $z = $ans"

elif [ $x -eq "3" ];then
	echo "Introduce el primer numero: "
	read y
	echo "introduce el segundo numero: "
	read z
	ans=$(( $y / $z ))
	echo "$y / $z = $ans"

elif [ $x -eq "4" ];then
	echo "Introduce el primer numero: "
	read y
	echo "introduce el segundo numero: "
	read z
	ans=$(( $z * $y ))
	echo "$z * $y = $ans"
else 
	echo "No has seleccionat una opció"
fi

	
