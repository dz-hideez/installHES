

# install PHP 7.3
#Add PHP 7.3 Remi repository
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
yum -y install epel-release yum-utils

#Disable repo for PHP 5.4
yum-config-manager --disable remi-php54
yum-config-manager --enable remi-php73

yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json

#enable and restart  php-fpm.service
systemctl enable  php-fpm
systemctl restart php-fpm

# install phpMyAdmin

yum -y  install epel-release
yum -y install phpmyadmin

cat > /etc/nginx/conf.d/phpmyadmin.conf << EOF
server {
  location /phpMyAdmin {
         root /usr/share/;
         index index.php index.html index.htm;
         location ~ ^/phpMyAdmin/(.+\.php)\$ {
                 try_files \$uri = 404;
                 root /usr/share/;
                 #fastcgi_pass unix:/run/php-fpm/www.sock;
                 fastcgi_pass 127.0.0.1:9000;
                 fastcgi_index index.php;
                 fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                include /etc/nginx/fastcgi_params;
         }
         location ~* ^/phpMyAdmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))\$ {
                 root /usr/share/;
         }
  }
  location /phpmyadmin {
      rewrite ^/* /phpMyAdmin last;
  }
}
EOF

#Open mySQL for all ip
echo "bind-address = 0.0.0.0" >> /etc/my.cnf 


read -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "use mysql; UPDATE user SET Host='%' WHERE User='root' AND Host='localhost'; FLUSH PRIVILEGES;"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"


if [ $? -eq 0 ]; then
  echo Good
else
  echo no Good
fi

systemctl restart mysqld
systemctl reload nginx

#chown nginx:nginx /var/lib/php/session/
#chown -R nginx:nginx /usr/share/phpMyAdmin/
chmod 777  /var/lib/php/session/




#nano /etc/php-fpm.d/www.conf 
#listen.owner = nginx
#listen.group = nginx

#ALTER USER 'user_name'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_password'; 











