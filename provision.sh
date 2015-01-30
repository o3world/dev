#!/bin/sh


# ---- set locale, noninteractive install, additional repos

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

export DEBIAN_FRONTEND=noninteractive

add-apt-repository -y ppa:ondrej/php5-5.6
add-apt-repository -y ppa:nginx/stable
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


# ---- php, php-fpm

apt-get install -y php5-cli php5-fpm php5-mysql php5-curl php5-gd php5-mcrypt

cd /etc/php5/cli
sed -i 's/^;date.timezone.*/date.timezone = America\/New_York/' php.ini

cd ../fpm
sed -i 's/^;date.timezone.*/date.timezone = America\/New_York/' php.ini
sed -i 's/^zlib.output_compression.*/zlib.output_compression = On/' php.ini
sed -i 's/^upload_max_filesize.*/upload_max_filesize = 128M/' php.ini
sed -i 's/^post_max_size.*/post_max_size = 160M/' php.ini


# ---- mysql

apt-get install -y mysql-client-5.6 mysql-server-5.6

cd /etc/mysql
sed -i '/^\[mysqld\].*/aexplicit_defaults_for_timestamp = 1' my.cnf
sed -i 's/^key_buffer[^_]/key_buffer_size/' my.cnf
sed -i 's/^max_allowed_packet.*/max_allowed_packet = 128M/' my.cnf
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' my.cnf

mysql -e "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION; UPDATE mysql.user SET Password = PASSWORD('vagrant') WHERE User='root'; FLUSH PRIVILEGES;"
mysqladmin -uroot -pvagrant shutdown

if [ -f /sync/.mysql.tgz ]
then
	cd /
	rm -rf /var/lib/mysql
	tar xvfp /sync/.mysql.tgz
fi

(crontab -l ; echo "*/15 * * * * tar cvfp /sync/.mysql.tgz /var/lib/mysql > /dev/null 2>&1") | crontab -


# ---- redis, php-redis

apt-get install -y redis-server php5-redis

cd /etc/redis
sed -i 's/^bind.*/bind 0.0.0.0/' redis.conf


# ---- nginx

mkdir /etc/nginx
mv /tmp/nginx.conf /etc/nginx/nginx.conf
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" nginx


# ---- post-provision cleanup

apt-get clean
apt-get autoremove
rm -rf /tmp/*
