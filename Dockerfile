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

VOLUME /etc/kamailio
CMD ["bash"]
