#!/bin/bash

git clone git://github.com/processwire/processwire.git -b master /var/www/html
chown -R www-data:www-data /var/www/html

mkdir -p /usr/local/etc/php/conf.d

cat > /usr/local/etc/php/conf.d/local.ini << EOF
extension=gd.so
extension=intl.so
extension=mysqli.so
extension=opcache.so
extension=pdo.so
extension=pdo_mysql.so
extension=zip.so
EOF

source /etc/apache2/envvars
exec apache2ctl -D FOREGROUND
