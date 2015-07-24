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


# ---- solr

# java
sudo aptitude update
sudo aptitude install -y solr-jetty default-jdk

# jetty config
sudo sed -i 's/NO_START=.*/NO_START=0/' /etc/default/jetty8
sudo sed -i 's/#JETTY_HOST=.*/JETTY_HOST=0.0.0.0/' /etc/default/jetty8
sudo sed -i 's/#JETTY_PORT=.*/JETTY_PORT=8983/' /etc/default/jetty8
sudo sed -i 's/#JETTY_PORT=.*/JETTY_PORT=8983/' /etc/default/jetty8
echo 'JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' | sudo tee -a /etc/default/jetty8

# solr config
sudo cp /vagrant/solr-conf/* /etc/solr/conf

sudo service jetty8 restart


# ---- post-provision cleanup

apt-get clean
apt-get autoremove
rm -rf /tmp/*
