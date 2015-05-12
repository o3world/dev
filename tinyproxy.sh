#!/bin/sh

if [ ! -f /usr/local/etc/tinyproxy.conf ]
then
	brew install tinyproxy
	TINYPROXY=/usr/local/Cellar/`/usr/local/sbin/tinyproxy -v|tr ' ' '/'`
	sed -i '' 's/^Allow 127\.0\.0\.1/#Allow 127\.0\.0\.1/' $TINYPROXY/etc/tinyproxy.conf
	mkdir -p $TINYPROXY/var/log/tinyproxy
	mkdir -p $TINYPROXY/var/run/tinyproxy
fi

echo "\non your device, set up an http proxy at this ip address on port 8888\n"
ifconfig|grep 'inet.*10\.'
echo "\ntinyproxy is now running... to stop it: ctrl-c\n"
/usr/local/sbin/tinyproxy -d
