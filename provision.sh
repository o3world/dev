#!/bin/sh


# ---- set locale, noninteractive install, additional repos

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y upgrade

apt-get install -y cowsay


# ---- swapfile

dd if=/dev/zero of=/swapfile bs=1024 count=2048k
mkswap /swapfile
swapon /swapfile
echo "/swapfile  none  swap  sw  0  0" >> /etc/fstab
echo 10 | sudo tee /proc/sys/vm/swappiness
chown root:root /swapfile
chmod 0600 /swapfile


# ---- sendmail

apt-get install -y sendmail
apt-get install -y mailutils


# ---- php, php-fpm

apt-get install -y php5-cli php5-fpm php5-curl php5-gd php5-mcrypt

cd /etc/php5/cli
sed -i 's/^;date.timezone.*/date.timezone = America\/New_York/' php.ini

cd ../fpm
sed -i 's/^;date.timezone.*/date.timezone = America\/New_York/' php.ini
sed -i 's/^zlib.output_compression.*/zlib.output_compression = On/' php.ini
sed -i 's/^upload_max_filesize.*/upload_max_filesize = 128M/' php.ini
sed -i 's/^post_max_size.*/post_max_size = 160M/' php.ini

cd /
php5enmod mcrypt
service php5-fpm restart

mkdir /sync/phpinfo
echo "<?php phpinfo();" > /sync/phpinfo/index.php


# ---- mysql, php-mysql

apt-get install -y mysql-client mysql-server php5-mysql

cd /etc/mysql/mysql.conf.d
sed -i '/^\[mysqld\].*/aexplicit_defaults_for_timestamp = 1' mysqld.cnf
sed -i 's/^key_buffer[^_]/key_buffer_size/' mysqld.cnf
sed -i 's/^max_allowed_packet.*/max_allowed_packet = 128M/' mysqld.cnf
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' mysqld.cnf

mysql -e "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION; UPDATE mysql.user SET Password = PASSWORD('vagrant') WHERE User='root'; FLUSH PRIVILEGES;"
mysqladmin -uroot -pvagrant shutdown

/etc/init.d/mysql restart


# ---- postgres, php-pgsql

apt-get install -y postgresql php5-pgsql

cd /etc/postgresql/`ls /etc/postgresql`/main
sed -i "/^\#listen_addresses.*/alisten_addresses = '*'" postgresql.conf

sudo -u postgres bash -c "psql -c \"CREATE USER root WITH PASSWORD 'vagrant';\""
echo "host all root all password" >> pg_hba.conf

/etc/init.d/postgresql restart


# ---- redis, php-redis

apt-get install -y redis-server php5-redis

cd /etc/redis
sed -i 's/^bind.*/bind 0.0.0.0/' redis.conf

/etc/init.d/redis-server restart


# ---- wkhtmltopdf
apt-get install -y wkhtmltopdf
apt-get install -y xvfb
echo 'xvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > /usr/bin/wkhtmltopdf.sh
chmod a+rx /usr/bin/wkhtmltopdf.sh
ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

# --- phantomjs
apt-get install -y phantomjs
chmod a+rx /usr/bin/phantomjs
ln -s /usr/bin/phantomjs /usr/local/bin/phantomjs

# ---- nginx

mkdir /etc/nginx
cd /etc/nginx

openssl genrsa -out dev.key 2048
openssl req -new -subj '/CN=*.local.dev' -key dev.key -out dev.csr
openssl x509 -req -days 1825 -in dev.csr -signkey dev.key -out dev.crt
cp dev.crt /vagrant

mv /tmp/nginx.conf .
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" nginx


# ---- post-provision cleanup

apt-get clean
apt-get autoremove
rm -rf /tmp/*
