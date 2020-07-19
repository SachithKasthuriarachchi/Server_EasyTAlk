FROM debian:buster
LABEL maintainer="EasyTalk"

RUN \
	apt-get update \
	&& apt-get -y install gcc flex bison default-libmysqlclient-dev make libssl-dev vim \
	&& apt-get -y install libcurl4-openssl-dev libxml2-dev libpcre3-dev ntp \
	&& apt -y install mariadb-server \
	&& apt -y install kamailio kamailio-mysql-modules \
	&& apt -y install kamailio-extra-modules \
	&& apt -y install kamailio-outbound-modules \
	&& apt -y install kamailio-presence-modules \
	&& apt -y install kamailio-tls-modules \
	&& apt -y install kamailio-utils-modules \
	&& apt -y install kamailio-websocket-modules

RUN \
	sed "/^[# ]*SIP_DOMAIN/cSIP_DOMAIN=IP_ADDR" -i /etc/kamailio/kamctlrc \
	&& sed "/^[# ]*DBENGINE/cDBENGINE=MYSQL" -i /etc/kamailio/kamctlrc \
	&& sed "/^[# ]*DBRWUSER/cDBRWUSER=\"kamailio\"" -i /etc/kamailio/kamctlrc \
	&& sed "/^[# ]*DBRWPW/cDBRWPW=\"changeme\"" -i /etc/kamailio/kamctlrc \
	&& sed "/^[# ]*DBROUSER/cDBROUSER=\"kamailioro\"" -i /etc/kamailio/kamctlrc \
	&& sed "/^[# ]*DBROPW/cDBROPW=\"changeme_2\"" -i /etc/kamailio/kamctlrc \
	&& sed "/^[# ]*DBACCESSHOST/cDBACCESSHOST=LAN_ADDR_MACHINE" -i /etc/kamailio/kamctlrc \
	&& sed "/^[# ]*PID_FILE/cPID_FILE=\/var\/run\/kamailio\/kamailio.pid" -i /etc/kamailio/kamctlrc

RUN \
	sed "/#!KAMAILIO/ a #!define WITH_MYSQL" -i /etc/kamailio/kamailio.cfg \
	&& sed "/#!define WITH_MYSQL/ a #!define WITH_AUTH" -i /etc/kamailio/kamailio.cfg \
	&& sed "/#!define WITH_AUTH/ a #!define WITH_USRLOCDB" -i /etc/kamailio/kamailio.cfg \
	&& sed "/#!define WITH_USRLOCDB/ a #!define WITH_ANTIFLOOD" -i /etc/kamailio/kamailio.cfg \
	&& sed "/#!define WITH_ANTIFLOOD/ a #!define WITH_PRESENCE" -i /etc/kamailio/kamailio.cfg \
	&& sed "/#!define WITH_PRESENCE/ a #!define WITH_ACCDB" -i /etc/kamailio/kamailio.cfg \
	&& sed "/#!define DBURL \"mysql:\/\/kamailio:kamailiorw@localhost\/kamailio\"/c#!define DBURL \"mysql:\/\/kamailio:changeme@localhost\/kamailio\"" -i /etc/kamailio/kamailio.cfg \
	&& sed "/# alias=\"sip.mydomain.com\"/calias=IP_ADDR" -i /etc/kamailio/kamailio.cfg \ 
	&& sed "/friendly-scanner/ i \\\tif (\$ua =~ \"(friendly-scanner|sipvicious|sipcli)\") {\n\t\txlog(\"L_INFO\",\"script kiddies from IP:\$si:\$sp - \$ua n\");\n\t\t\$sht(ipban=>\$si) = 1;\n\t\tsl_send_reply(\"200\",\"OK\");\n\t\texit;\n\t}\n\tif(\$au =~ \"(=)|(--)|(')|(#)|(%27)|(%24)\" and \$au != \$null) {\n\t\txlog(\"L_INFO\",\"[R-REQINIT:\$ci] sql injection from IP:\$si:\$sp - \$au n\");\n\t\t\$sht(ipban=>\$si) = 1;\n\t\texit;\n\t}" -i /etc/kamailio/kamailio.cfg 

RUN \
	sed "/^[#]*RUN_KAMAILIO/cRUN_KAMAILIO=yes" -i /etc/default/kamailio \
	&& sed "/^[#]*USER/cUSER=kamailio" -i /etc/default/kamailio \
	&& sed "/^[#]*GROUP/cGROUP=kamailio" -i /etc/default/kamailio \
	&& sed "/^[#]*SHM_MEMORY/cSHM_MEMORY=128" -i /etc/default/kamailio \
	&& sed "/^[#]*PKG_MEMORY/cPKG_MEMORY=4" -i /etc/default/kamailio \
	&& sed "/^[#]*CFGFILE/cCFGFILE=\/etc\/kamailio\/kamailio.cfg" -i /etc/default/kamailio

VOLUME /etc/kamailio
CMD ["bash"]
