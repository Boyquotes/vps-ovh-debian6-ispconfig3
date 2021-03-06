#!/bin/bash
#Install debian squeeze et ispconfig 3
host=`hostname -f`
apt-get update

apt-get -y install ntp ntpdate

#Courier POSTFIX
apt-get -y install postfix postfix-mysql postfix-doc mysql-client mysql-server courier-authdaemon courier-authlib-mysql courier-pop courier-pop-ssl courier-imap courier-imap-ssl libsasl2-2 libsasl2-modules libsasl2-modules-sql sasl2-bin libpam-mysql openssl courier-maildrop getmail4 rkhunter binutils sudo

cd /etc/courier
rm -f /etc/courier/imapd.pem
rm -f /etc/courier/pop3d.pem

sed -i "s/localhost/$host/g" /etc/courier/imapd.cnf
sed -i "s/localhost/$host/g" /etc/courier/pop3d.cnf

mkimapdcert
mkpop3dcert

/etc/init.d/courier-imap-ssl restart
/etc/init.d/courier-pop-ssl restart

#Amavsid-new , Spamassasin , Clamav
apt-get -y install amavisd-new spamassassin clamav clamav-daemon zoo arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl libnet-dns-perl

#APACHE PHP
apt-get install -y apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php5 php5 php5-common php5-gd php5-mysql php5-imap phpmyadmin php5-cli php5-cgi libapache2-mod-fcgid apache2-suexec php-pear php-auth php5-mcrypt mcrypt php5-imagick imagemagick libapache2-mod-suphp libruby libapache2-mod-ruby

a2enmod suexec rewrite ssl actions include
a2enmod dav_fs dav auth_digest
/etc/init.d/apache2 restart

#PureFTP et Quota
apt-get -y install pure-ftpd-common pure-ftpd-mysql quota quotatool

sed -i 's/VIRTUALCHROOT=false/VIRTUALCHROOT=true/g' /etc/default/pure-ftpd-common

/etc/init.d/openbsd-inetd restart
echo 1 > /etc/pure-ftpd/conf/TLS
mkdir -p /etc/ssl/private/
openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
chmod 600 /etc/ssl/private/pure-ftpd.pem
/etc/init.d/pure-ftpd-mysql restart

sed -i 's/errors=remount-ro/errors=remount-ro usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/g' /etc/fstab
mount -o remount /
quotacheck -avugm
quotaon -avug

#BIND9
apt-get -y install bind9 dnsutils

#Stats et logs
apt-get -y install vlogger webalizer awstats
sed  's/^/#/g' /etc/cron.d/awstats
#nano /etc/cron.d/awstats

#Jailkit
apt-get -y install build-essential autoconf automake1.9 libtool flex bison debhelper
cd /tmp
wget http://olivier.sessink.nl/jailkit/jailkit-2.13.tar.gz
tar xvfz jailkit-2.13.tar.gz
cd jailkit-2.13
./debian/rules binary
cd ..
dpkg -i jailkit_2.13-1_*.deb
rm -rf jailkit-2.13*

#Securite
apt-get -y install fail2ban
wget http://www.codes-libres.org/scripts/jail.local -O /etc/fail2ban/filter.d/jail.local
wget http://www.codes-libres.org/scripts/pureftpd.conf -O /etc/fail2ban/filter.d/pureftpd.conf
wget http://www.codes-libres.org/scripts/courierpop3.conf -O /etc/fail2ban/filter.d/courierpop3.conf
wget http://www.codes-libres.org/scripts/courierpop3s.conf -O /etc/fail2ban/filter.d/courierpop3s.conf
wget http://www.codes-libres.org/scripts/courierimap.conf -O /etc/fail2ban/filter.d/courierimap.conf
wget http://www.codes-libres.org/scripts/courierimaps.conf -O /etc/fail2ban/filter.d/courierimaps.conf

/etc/init.d/fail2ban restart

#Webmail
apt-get -y install squirrelmail
ln -s /usr/share/squirrelmail/ /var/www/webmail
squirrelmail-configure

cd /tmp
wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
tar xfz ISPConfig-3-stable.tar.gz
cd ispconfig3_install/install/

php -q install.php
echo "http://$hostname:8080"

