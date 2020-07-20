#!/bin/sh
mysql --user=root <<_EOF_
alter user 'root'@'localhost' identified by 'password';
_EOF_

printf "password\nn\ny\ny\ny\ny\n" | mysql_secure_installation
