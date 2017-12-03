#!/bin/bash
# Installer for Ebot-CSGO and Ebot-WEB by Vince52

# This script will work on Debian and Ubuntu
# This is not bullet-proof. So I'm not responsible
# of anything if you use this script.
# If you see anything, please let me know here:
# http://forum.esport-tools.net/d/35-automatic-script-not-ready


# Try to get our IP from the system and fallback to the Internet.
# CHECK NAT
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)

	
	# 2) Install SERVER-REQUIREMENTS
	apt-get update
	apt-get upgrade -y
	apt-get dist-upgrade -y
	apt-get install apache2 gcc make libxml2-dev php5-curl autoconf ca-certificates unzip curl libcurl4-openssl-dev sudo pkg-config libssl-dev screen libapache2-mod-php5 -y
	apt-get install mysql-server php5-mysql -y
	
	# 3) INSTALL PHP
	

		
	# COMPILE AND INSTALL THE NEW PHP VERSION:
	mkdir /home/install
	cd /home/install
	wget http://be2.php.net/get/php-5.6.30.tar.bz2/from/this/mirror -O php-5.6.30.tar.bz2
	tar -xjvf php-5.6.30.tar.bz2
	cd php-5.6.30
	./configure --prefix /usr/local --with-mysql --enable-maintainer-zts --enable-sockets --with-openssl --with-pdo-mysql 
	make
	make install
	cd /home/install
	wget http://pecl.php.net/get/pthreads-2.0.10.tgz
	tar -xvzf pthreads-2.0.10.tgz
	cd pthreads-2.0.10
	/usr/local/bin/phpize
	./configure
	make
	make install
	echo 'date.timezone = Europe/Paris' >> /usr/local/lib/php.ini
	echo 'extension=pthreads.so' >> /usr/local/lib/php.ini

	
	# 4) INSTALL & CONFIG MYSQL SERVER (NEED TO FINISH IT)
	

	
	# create random password
	SQLPASSWORDEBOTV3="$(openssl rand -base64 12)"

	rootpasswd=root
	
		mysql -u root -p$rootpasswd -e "CREATE DATABASE ebotv3;"
		mysql -u root -p$rootpasswd -e "CREATE USER ebotv3@localhost IDENTIFIED BY '$SQLPASSWORDEBOTV3';"
		mysql -u root -p$rootpasswd -e "grant all privileges on ebotv3.* to 'ebotv3'@'localhost' with grant option;"
	
	
	
	# Variables to be set: $SQLPASSWORDEBOTV3
	
	# 5) INSTALL EBOT-CSGO
	
	
	cd /home
	wget https://github.com/deStrO/eBot-CSGO/archive/master.zip
	unzip master.zip
	mv eBot-CSGO-master ebot-csgo
	cd ebot-csgo
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
	apt-get install -y nodejs
	npm install socket.io archiver formidable forever
	curl -sS https://getcomposer.org/installer | php
	php composer.phar install
	# Command line of my ebot guide: cp config/config.ini.smp config/config.ini
	
	
	
	# Generate config.ini (need SQL DATABASE HERE $SQLPASSWORDEBOTV3)
	echo '; eBot - A bot for match management for CS:GO
; @license     http://creativecommons.org/licenses/by/3.0/ Creative Commons 3.0
; @author      Julien Pardons <julien.pardons@esport-tools.net>
; @version     3.0
; @date        21/10/2012

[BDD]
MYSQL_IP = "127.0.0.1"
MYSQL_PORT = "3306"
MYSQL_USER = "ebotv3"
MYSQL_PASS = "'$SQLPASSWORDEBOTV3'"
MYSQL_BASE = "ebotv3"

[Config]
BOT_IP = "'$IP'"
BOT_PORT = 12360
EXTERNAL_LOG_IP = "" ; use this in case your server isnt binded with the external IP (behind a NAT)
MANAGE_PLAYER = 1
DELAY_BUSY_SERVER = 120
NB_MAX_MATCHS = 0
PAUSE_METHOD = "nextRound" ; nextRound or instantConfirm or instantNoConfirm
NODE_STARTUP_METHOD = "node" ; binary file name or none in case you are starting it with forever or manually

[Match]
LO3_METHOD = "restart" ; restart or csay or esl
KO3_METHOD = "restart" ; restart or csay or esl
DEMO_DOWNLOAD = true ; true or false :: whether gotv demos will be downloaded from the gameserver after matchend or not
REMIND_RECORD = false ; true will print the 3x "Remember to record your own POV demos if needed!" messages, false will not
DAMAGE_REPORT = true ; true will print damage reports at end of round to players, false will not
USE_DELAY_END_RECORD = true ; use the tv_delay to record postpone the tv_stoprecord & upload

[MAPS]
MAP[] = "de_cache"
MAP[] = "de_season"
MAP[] = "de_dust2"
MAP[] = "de_nuke"
MAP[] = "de_inferno"
MAP[] = "de_train"
MAP[] = "de_mirage"
MAP[] = "de_cbble"
MAP[] = "de_overpass"

[WORKSHOP IDs]

[Settings]
COMMAND_STOP_DISABLED = false
RECORD_METHOD = "knifestart" ; matchstart or knifestart
DELAY_READY = true' > /home/ebot-csgo/config/config.ini


	
	
	# 6) INSTALL EBOT-WEB
	
	cd /home
	rm -R master*
	wget https://github.com/deStrO/eBot-CSGO-Web/archive/master.zip
	unzip master.zip
	mv eBot-CSGO-Web-master ebot-web
	cd ebot-web
	# cp config/app_user.yml.default config/app_user.yml
	
	# Generate app_user.yml
	echo "# ----------------------------------------------------------------------
# white space are VERY important, don't remove it or it will not work
# ----------------------------------------------------------------------

  log_match: /home/ebot-csgo/logs/log_match
  log_match_admin: /home/ebot-csgo/logs/log_match_admin
  demo_path: /home/ebot-csgo/demos
  
  default_max_round: 15
  default_rules: esl5on5
  default_overtime_max_round: 3
  default_overtime_startmoney: 16000

  # true or false, whether demos will be downloaded by the ebot server
  # the demos can be downloaded at the matchpage, if it's true

  demo_download: true

  ebot_ip: "$IP"
  ebot_port: 12360

  # lan or net, it's to display the server IP or the GO TV IP
  # net mode display only started match on home page
  mode: lan

  # set to 0 if you don't want a refresh
  refresh_time: 30

  # Toornament Configuration
  toornament_id:
  toornament_secret:
  toornament_api_key:
  toornament_plugin_key: test-123457890" > /home/ebot-web/config/app_user.yml
	
	# Generate databases.yml
rm /home/ebot-web/config/databases.yml
	echo "# You can find more information about this file on the symfony website:
# http://www.symfony-project.org/reference/1_4/en/07-Databases

all:
  doctrine:
    class: sfDoctrineDatabase
    param:
      dsn:      mysql:host=127.0.0.1;dbname=ebotv3
      username: ebotv3
      password: $SQLPASSWORDEBOTV3" > /home/ebot-web/config/databases.yml	
	
cd /home
cd ebot-web
mkdir cache
chown -R www-data *
chmod -R 777 cache

php symfony cc	
php symfony doctrine:build --all --no-confirmation
php symfony guard:create-user --is-super-admin admin@ebot admin admin
	
	# 7) CONFIG APACHE
a2enmod rewrite
	
	
	echo "Alias / /home/ebot-web/web/

<Directory /home/ebot-web/web/>
	AllowOverride All
	<IfVersion < 2.4>
		Order allow,deny
		allow from all
	</IfVersion>

	<IfVersion >= 2.4>
		Require all granted
	</IfVersion>
</Directory>" > /etc/apache2/sites-available/ebotv3.conf

	echo "Options +FollowSymLinks +ExecCGI

<IfModule mod_rewrite.c>
  RewriteEngine On

  # uncomment the following line, if you are having trouble
  # getting no_script_name to work
  RewriteBase /

  # we skip all files with .something
  #RewriteCond %{REQUEST_URI} \..+$
  #RewriteCond %{REQUEST_URI} !\.html$
  #RewriteRule .* - [L]

  # we check if the .html version is here (caching)
  RewriteRule ^$ index.html [QSA]
  RewriteRule ^([^.]+)$ $1.html [QSA]
  RewriteCond %{REQUEST_FILENAME} !-f

  # no, so we redirect to our front web controller
  RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>" > /home/ebot-web/web/.htaccess


a2ensite ebotv3.conf

rm -r /home/ebot-web/web/installation/
	
service apache2 reload

screen -d -m php /home/ebot-csgo/bootstrap.php
screen -ls

echo "screen -r pour voir le screen"
echo "ctrl A + D pour quitter le screen" 
