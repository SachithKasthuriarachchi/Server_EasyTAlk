#!/bin/sh

echo 'Enter a password for the Kamailio database user(read-write access): '
read PASSWORDRW

sed "/^[# ]*DBRWPW/cDBRWPW=\"$PASSWORDRW\"" -i /etc/kamailio/kamctlrc
sed "/#!define DBURL \"mysql:\/\/kamailio:kamailiorw@localhost\/kamailio\"/c#!define DBURL \"mysql:\/\/kamailio:${PASSWORDRW}@localhost\/kamailio\"" -i /etc/kamailio/kamailio.cfg
sed "/^[# ]*SIP_DOMAIN/cSIP_DOMAIN=$(hostname -I)" -i /etc/kamailio/kamctlrc
sed "/# alias=\"sip.mydomain.com\"/calias=$(hostname -I)" -i /etc/kamailio/kamailio.cfg

echo 'Enter a password for the Kamailio fatabase user(read only access): '
read PASSWORDRO

sed "/^[# ]*DBROPW/cDBROPW=\"$PASSWORDRO\"" -i /etc/kamailio/kamctlrc
echo 'Enter the MySQL password you wish to use: '
read PASSWORDSQL

/etc/init.d/mysql start
mysql --user=root <<_EOF_
alter user 'root'@'localhost' identified by '$PASSWORDSQL';
_EOF_

printf "$PASSWORDSQL\nn\ny\ny\ny\ny\n" | mysql_secure_installation
printf "$PASSWORDSQL\n"| kamdbctl create
