#Este script sirve para crear usuarios y otorgarles una carpeta de publicación web así como para instalar LAMP y el wordpress
#/bin/bash
sudo apt-get update

#Instala Aache
if ! [ -x "$(command -v apache2)" ]; then
  sudo apt-get install apache2
fi
#Comprueba que este activado el mod userdir y si no lo activa
FILE=/etc/apache2/mods-enabled/userdir.conf
if [ -f "$FILE" ]; then
  sudo a2enmod userdir  
  sudo systemctl restart apache2
fi


#Instala FTP y lo configura
if ! [ -x "$(command -v vsftpd)" ]; then
  sudo apt-get install vsftpd
  mv /etc/vsftpd.conf /etc/vsftpd.conforiginal
  touch /etc/vsftpd.chroot_list
  cat <<EOT >> /etc/vsftpd.conf
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
ftpd_banner=Bienvenidos al server de YUKI
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
local_root=/home/$USER
user_sub_token=$USER
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/vsftpd.pem
rsa_private_key_file=/etc/vsftpd.pem
ssl_enable=Yes
pasv_enable=Yes
pasv_min_port=10000
pasv_max_port=10100
allow_writeable_chroot=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
EOT
  sudo systemctl restart vsftpd
fi

#Comprueba que existen los certificados de vsftpd
basedir=/etc
files=(vsftpd.cer vsftpd.key vsftpd.pem)
found=
for file in ${files[@]}; do
    path="$basedir/$file"
    if [ -f "$path" ]; then
        echo "Ya esta creado el certificado"
        found=1
        break
    fi
done
if test ! "$found"; then
    sudo openssl req -x509 -nodes -keyout /etc/vsftpd.pem -out /etc/vsftpd.pem -days 365 -newkey rsa:2048
fi



#Crea un usuario si no existe ya
read -p "Introduce usuario : " nombre_usuario
read -s -p "Enter password : " password
egrep "^$nombre_usuario" /etc/passwd >/dev/null

if [ $? -eq 0 ]; then
	echo "El nombre de usuario $nombre_usuario ya existe!"
	exit 1
else
	pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	useradd -m -p $pass $nombre_usuario
	[ $? -eq 0 ] && echo -e "\nUsuario creado correctamente!" || echo "Hubo un fallo al crear el usuario!"
fi

sudo mkdir -p "/home/$nombre_usuario/public_html"

#Aqui puedes cambiar tu adaptador ___enp0s3___
ip4=$(/sbin/ip -o -4 addr list enp0s3 | awk '{print $4}' | cut -d/ -f1)
cat <<EOF >> /etc/hosts
$ip4 www.$nombre_usuario.com
EOF

#Configuración básica de apache
cat <<EOE >> /etc/apache2/sites-available/$nombre_usuario.conf
<VirtualHost $ip4:*>
	<Directory /home/$nombre_usuario/public_html>
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ServerName $nombre_usuario.com
	ServerAdmin webmaster@$nombre_usuario.com
	ServerAlias www.$nombre_usuario.com
	DocumentRoot /home/$nombre_usuario/public_html
	DirectoryIndex index.html index.php

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOE


#Activación de la conf de apache
sudo a2ensite $nombre_usuario.conf
sudo systemctl reload apache2

#Creacion de SSL Apache
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /home/$nombre_usuario/$nombre_usuario.key -out /home/$nombre_usuario/$nombre_usuario.crt

cat <<EOE >> /etc/apache2/sites-available/ssl$nombre_usuario.conf
<IfModule mod_ssl.c>
	<VirtualHost $ip4:443>
		
		ServerName $nombre_usuario.com
		ServerAdmin webmaster@$nombre_usuario.com
		ServerAlias www.$nombre_usuario.com
		DocumentRoot /home/$nombre_usuario/public_html
		DirectoryIndex index.php index.html	
		<Directory /home/$nombre_usuario/public_html>
			Options Indexes FollowSymLinks Multiviews
			AllowOverride All
			Require all granted
		</Directory>	

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		#   SSL Engine Switch:
		#   Enable/Disable SSL for this virtual host.
		SSLEngine On		
		SSLCertificateFile	/home/$nombre_usuario/$nombre_usuario.crt
		SSLCertificateKeyFile /home/$nombre_usuario/$nombre_usuario.key
	
		<FilesMatch "\.(cgi|shtml|phtml|php)$">
				SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
				SSLOptions +StdEnvVars
		</Directory>		

	</VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOE

#Activa SSL
sudo a2enmod ssl
sudo a2ensite ssl$nombre_usuario.conf
sudo systemctl restart apache2

#Creación de web de prueba
cat <<EOT >> /home/$nombre_usuario/public_html/index.html
<h1>Web de $nombre_usuario creada</h1>
EOT

#INSTALACION DE WORDPRESS
#ES NECESARIO POSEER UN USUARIO CON PRIVILEGIOS

echo "============================================"
echo "Script de instalación de Wordpress"
echo "============================================"

echo "Deseas instalar? (s/n)"
read -e run
if [ "$run" == n ] ; then
  exit
else
  echo "============================================"
  echo "Instalando wordpress ahora mismo"
  echo "============================================"

#Prueba que este instalado mysql
  if ! [ -x "$(command -v mysql)" ]; then
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://ftp.utexas.edu/mariadb/repo/10.3/ubuntu bionic main'
    sudo apt update
    sudo apt install mariadb-server
    sudo mysql_secure_installation
  fi
#Prueba que este instalado php
  if ! [ -x "$(command -v php)" ]; then
    sudo apt install php libapache2-mod-php
    sudo apt install php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip   
  fi


#CREAR USUARIO Y BASE DE DATOS	
  echo "Introduce tu contraseña del usuario con privilegios de la base de datos"
  echo "La contraseña no se mostrara cuando se escriba"
  read -s rootpasswd
#Pedira contraseña para ejecutar cada una de las lineas por las propias directivas de seguridad de mysql
  sudo mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${nombre_usuario} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
  sudo mysql -uroot -p${rootpasswd} -e "CREATE USER ${nombre_usuario}@localhost IDENTIFIED BY '${password}';"
  sudo mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${nombre_usuario}.* TO '${nombre_usuario}'@'localhost';"
  sudo mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"


  sudo systemctl restart apache2

#Cambia a la carpeta de usuario
  cd /home/$nombre_usuario/public_html
#descarga wordpress
  sudo wget https://wordpress.org/latest.tar.gz
#descomprime wordpress
  sudo tar -zxvf latest.tar.gz
#cambia de directorio
  cd wordpress
#copia los archivos al directorio padre
  sudo cp -rf . ..
#salimos al directorio padre
  cd ..
#eliminamos la carpeta wordpress
  sudo rm -R wordpress
  sudo rm index.html
#creacion wp config
  sudo cp wp-config-sample.php wp-config.php
#se definen los parametros de la base de datos
  sudo sed -i "s/database_name_here/$nombre_usuario/g" wp-config.php
  sudo sed -i "s/username_here/$nombre_usuario/g" wp-config.php
  sudo sed -i "s/password_here/$password/g" wp-config.php

#set WP salts
  sudo perl -i -pe'
    BEGIN {
      @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
      push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
      sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
    }
    s/put your unique phrase here/salt()/ge
  ' wp-config.php

#creacion de la carpeta de subidas 
  sudo mkdir wp-content/uploads
  sudo chmod 775 wp-content/uploads
  echo "Ahora borro lo que sobra"
#borra el archivo latest.tar.gz
  sudo rm latest.tar.gz
  echo "========================="
  echo "Instalación completa"
  echo "========================="
fi
