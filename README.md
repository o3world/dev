dev
====

**Ubuntu 15.10 LEMP for Vagrant**

Compatible with
----------

* WordPress
* Drupal
* Magento
* Laravel/Lumen

Prerequisites
----------

* You are running the latest version of macOS
* You have installed Homebrew
* You have used `brew install ruby` to install/update Ruby
* You have installed the latest versions of VirtualBox and Vagrant
* You have NOT already provisioned another Vagrant VM named dev (if so, remove or rename it)

Installation
----------

* `git clone git@github.com:o3world/dev.git dev`
* `cd dev` 
* `vagrant up` to create and provision the VM (runs `provision.sh`) — this may take 10 minutes or more
* `vagrant reload` to ensure that all services are started

Configuration notes for each service/application is detailed below
* All configurations based off of shipped defaults and vendor recommendations

Test VM by running `sh dnsmasq.sh` and then visiting http://phpinfo.local.dev


Need to install the Solr Search compatible version of this VM? Follow the instructions above, and then scroll down to the “Solr” portion of this document.

VM Overview
----------

**Dev**
* hostname: vagrant.local.dev
* IP address:  192.168.200.2
* ssh user:  vagrant / vagrant
* system user:  root / vagrant
* ~/sync linked to /sync via NFS

**Solr**
* vaIP address: 192.168.200.3
* Solr port: 8983
* ssh user: vagrant / vagrant
* system user: root / vagrant

VM Specifications
----------

* 1GB ram
* 8MB vram
* 1 cpu
* 50% cpu limit
* 2GB swapfile
* Forwarded ports: 80/8080, 3306, 5432, 6379

Dnsmasq
----------

This is an optional tool for your host machine.

* It will map any host name ending in `.local.dev` (or simply `.dev` for now if you are using the Solr branch) to the IP address of the VM
* You will then not have to “hack” `/etc/hosts` for each new project/site

`sh dnsmasq.sh` will use `brew` to install and configure the Dnsmasq service

You may still edit `/etc/hosts` at will.

Tinyproxy
----------

`sh tinyproxy.sh` will use `brew` to install, configure and run a Tinyproxy server

* A message will display the IP address and port by which your VM may be accessed by any device sharing the same network… with an HTTP Proxy configured on your mobile device at that address, you may test changes to your application using a native browser, instantaneously.

Platform Compatibility Notes
----------

* Wordpress
  - set open permissions for content uploads:  `chmod -R 777 wp-content/uploads` 
* Drupal
  - to avoid file permissions woes in general:  `chmod -R 777 sites/default` 
* Magento
  - edit `/app/etc/local.xml` to change `session_save` from `[files]` to `[db]` 
* Laravel / Lumen
  - `composer` and `artisan` commands should be executed on the host OS

Installed Packages
----------

* PHP 5.6 with mysql, pgsql, curl, gd, mcrypt, fpm, redis
* Nginx 1.6
* MySQL 5.6
* PostgreSQL 9.4.4
* Redis 2.8 — added to mimic behavior of Pantheon instance with Redis enabled sendmail
* cowsay — used to display reassuring `I am ready!` message on boot

PHP
----------

configuration → `/etc/php5/cli/php.ini` — `/etc/php5/fpm/php.ini` 
logging → `/var/log/php5-fpm.log` 

* `date.timezone``= America/New_York` — to encourage an East Coast state of mind
* `zlib.output_compression``= On` — to enable output compression
* `upload_max_filesize``= 128M` — to allow large file uploads
* `post_max_size``= 160M` — to further accommodate large file uploads

Nginx
----------

configuration → `/etc/nginx/nginx.conf` 
logging → `/var/log/nginx` 

* `charset ``utf-8;` — to enforce default charset of utf-8
* `gzip ``on;` — to enable output compression
* `client_max_body_size ``160m;` — to match `post_max_size` PHP setting
* `listen 80` and `listen 443` — SSL enabled with`dev.crt` created during provisioning
* `server_name ``~^(?<site>[a-z0-9\x2d\x2e]+)\.local.dev$;` — for dynamic/variable server name
* `fastcgi_buffers`` 8 16k;` and `fastcgi_buffer_size`` 32k;` — generally recommended settings
* `fastcgi_read_timeout`` 180;` — to prevent timeout errors

* `dev.crt` may be imported into Keychain Access for “all green” status in most browsers
  * with the login keychain highlighted, use File > Import Items to add `dev.crt` 
  * right-click on *.local.dev and choose Get Info and expand Trust
  * for “When using this certificate:" choose Always Trust
  * enter your OS X login password to confirm
* desired`<site>.local.dev` host name parsed via regex from incoming request
  * regex used expects lowercase alphanumeric string, which may include `-` and `.` 
  * prefix of host name — `$site` — automatically mapped to subdirectory of `/sync` 
  * if `/sync/$site/public` exists, document root moved “up” to accommodate Laravel/Lumen
  * example: visiting `http://phpinfo.local.dev` will access `/sync/phpinfo/index.php` 

MySQL
----------

configuration → `/etc/mysql/mysql.conf.d/mysqld.cnf` 
logging → `/var/log/mysql` 

* `explicit_defaults_for_timestamp``= 1` — for backward-compatibility of TIMESTAMP defaults
* `key_buffer` replaced with `key_buffer_size` — to account for renamed directive
* `max_allowed_packet``= 128M` — to prevent errors during large import/export operations
* `bind-address``= 0.0.0.0` — to allow external access to MySQL

  * to connect from host OS:  `mysql -uroot -pvagrant -hvagrant.local.dev` 
  * or, use Sequel Pro

After creating your box, you’ll need to create any databases required for your project. One quick solution is to export the table data from a staging environment (e.g. Pantheon) and import it into a new database.

Be sure to confirm that the import was successful. Old templates being loaded can indicate a bad import. In this case, make sure you know when the export was generated, that it’s the export you were expecting, and try to import again. Failing that, get a local database dump from another dev.

Postgre SQL
----------

configuration → `/etc/postgresql/9.4/main/postgresql.conf` and `pg_hba.conf` 
logging → `/var/log/postgresql` 

* `listen_addresses = ``‘*'` — to allow external access to PostgreSQL
* `host all root all password` to allow “root” user to connect freely


* create database in an ssh session
  * `sudo -u postgres psql` 
  * `CREATE DATABASE``dbname``WITH OWNER = root;`

* manage from host OS with PSequel
  * specify vagrant.local.dev for host
  * use root and vagrant  for username, password
  * remember to specific database name (dbname in above example)

Redis
----------

configuration → `/etc/redis/redis.conf` 
logging → `/var/log/redis` 

* `bind`` 0.0.0.0` to allow external access to Redis

  * to connect from host OS:  `redis-cli` 
  * to view all stored keys:  `keys *` 

Solr
----------

**Boot and provision the solr box**

  1. Navigate to wherever your dev box is located in Terminal
  2. Checkout the `solr` git branch - `git checkout solr` 
  3. Boot and provision your solr box - `vagrant up` (if you already have your dev vm running, you just need to run `vagrant up solr`)
  4. Now your Solr server should be running at http://192.168.200.3:8983
  5. Feel free to browse the Solr admin at http://192.168.200.3:8983/solr/admin

Note: You can run vm-specific vagrant commands from your host machine by simply adding “solr” or “dev” to the ends of your commands (e.g. `vagrant ssh solr`, `vagrant halt dev`). Commands run without specifying a box will either apply to both, or fail with a warning asking you to specify one.


**Configure Drupal + apachesolr module**
  1. `vagrant ssh dev` - from the directory that your Vagrantfile is in
  2. Disable the Pantheon apachesolr module in Drupal (feel free to use drush to accomplish this `drush pm-disable -y pantheon_apachesolr`)
  3. Enable the apachesolr module (`drush en -y apachesolr`)
  4. Log in to the Drupal admin and navigate to the Apache Solr search settings page `/admin/config/search/apachesolr/settings/solr/edit` 
  5. Set the Solr server URL to `http://192.168.200.3:8983/solr` 
  6. Make sure Read & Write is selected for the Index write access
  7. Check the box next to “Commit changes after the index process has submitted them”
  8. Test the connection to make sure Drupal can communicate with your local Solr server


**General config info**

configuration → `/etc/solr/conf`
logging → `/var/log/jetty8` 

**Manually committing changes to Solr index**

Visit this URL in a browser or use curl/wget from a shell prompt: http://192.168.200.3:8983/solr/update?commit=true

----------

**Enjoy your new, full-fledged web application development platform!**
