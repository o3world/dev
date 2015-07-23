#!/bin/sh


# ---- set locale, noninteractive install, additional repos

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

export DEBIAN_FRONTEND=noninteractive

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


# ---- nginx

mkdir /etc/nginx
mv /tmp/nginx.conf /etc/nginx/nginx.conf
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" nginx

# ---- solr

# - java jdk
sudo apt-get -y install openjdk-7-jdk
mkdir /usr/java
ln -s /usr/lib/jvm/java-7-openjdk-amd64 /usr/java/default

# - solr-tomcat
sudo apt-get -y install solr-tomcat

# ---- post-provision cleanup

apt-get clean
apt-get autoremove
rm -rf /tmp/*
