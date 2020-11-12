# Server_EasyTalk
## Introduction
This is the server responsible for the SIP call handling in EasyTalk mobile application. The app.js handles the user authentication part while the dockerfile represents the Kamailio server responsible for the SIP call handling. The authentication server listens on port 3000 while the Kamailio server listens to ports 5060 and 5061 for SIP requests.

![Server Scenario](server.png)

## Quick Start Guide
In this document we are guiding you to set-up your own VoIP server compatible with the EasyTalk app. We will walk you through the following topics.(Please note that this guide is based on the Ubuntu 20.04, the commands can be slightly changed for other linux based systems)

- Installing Dependencies for Authentication Server
  - Visual Studio Code and Git
  - Node.js and npm
  - MongoDB
- Installing Kamailio Server
- Configuring Kamailio Server
  - Configuring kamctlrc
  - Configuring kamailio.cfg
  - Configuring kamailio
  - Generating the Database
- Running the Server
  - Running the Kamailio Server
  - Running the Authentication Server

### Installation Guide
#### Installing Dependencies for Authentication Server
##### Visual Studio Code and GIT

Installing VS Code is as easy as executing the following command.
```sh
>> sudo snap install --classic code
```
Next we need to install Git in our system so that we can easily clone this repository and go on with version controlling. To do that execute the following commands in the terminal.

```sh
>> sudo apt update
>> sudo apt install git
```

##### Node.js and npm

We need Node runtime to execute our javascript based Authentication server. Since we need to install certain dependencies(bcrypt, express) for our server it is easy for us to first install the node package manager(npm).

```sh
>> sudo apt install nodejs npm
```
Next, install the above-mentioned dependencies using npm.

```sh
>> npm install bcrypt express
```

##### MongoDB

The MongoDB is needed to store the credentials of the users in Authentication server. Follow these commands.

```sh
>> sudo apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common
>> wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
>> sudo add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse'
>> sudo apt install mongodb-org
```

#### Installing Kamailio Server

First of all, install the necessary dependencies required to run the Kamailio server on your machine using following commands.

```sh
>> sudo apt-get -y install gcc flex bison default-libmysqlclient-dev make libssl-dev nano
>> sudo apt-get -y install libcurl4-openssl-dev libxml2-dev libpcre3-dev ntp
>> sudo apt-get install --reinstall build-essential
>> sudo apt -y install mariadb-server
```
The MariaDB server is required by the Kamailio server to store the user information. We need to set-up the MySQL server on our system. To do that, run the below command and press 'Enter' for the first prompt(since this is a fresh installation of MySQL there can not be a 'previous root password'. Then enter 'y' for each subsequent prompts(please enter a new root user password when prompted).

```sh
>> sudo mysql_secure_installation
```

Next, install the Kamailio server and related modules as follows.

```sh
>> sudo apt -y install kamailio kamailio-mysql-modules
>> sudo apt -y install kamailio-extra-modules
>> sudo apt -y install kamailio-outbound-modules
>> sudo apt -y install kamailio-presence-modules
>> sudo apt -y install kamailio-tls-modules
>> sudo apt -y install kamailio-utils-modules
>> sudo apt -y install kamailio-websocket-modules
```

Now, we have installed all the necessary dependencies in our machine to run the two servers. Next, we need to configure our Kamailio server.

#### Configuring Kamailio Server

Before following any command you need to know the IP address of your machine. If you are installing this server on a Virtual Machine it is easy if you select the *bridged adapter* for the network. Then, execute the following command and you will have the IP address of your machine.

```sh
>> hostname -I
```
##### Configuring kamctlrc
Edit the *kamctlrc* file located on the `/etc/kamailio` folder. We are using *nano* editor for this tutorial.

```sh
>> nano -w /etc/kamailio/kamctlrc
```
Now, edit this file as below.
1. Start by uncommenting *SIP_DOMAIN* and insert the **IP address of your machiene**.
1. Uncomment *DBENGINE* line and make certain it points to *MYSQL*.
1. Uncomment the following line: *DBRWUSER="kamailio"*.
1. Uncomment the *DBRWPW* line and insert **your own password** between the quotes.
1. Uncomment the following line: *DBROUSER="kamailioro"*.
1. Uncomment the *DBROPW* line and **insert a different password** between the quotes.
1. Uncomment the *DBACCESSHOST* line and insert the **IP address of your machiene**.
1. Uncomment the *CHARSET* line and make it point to *"latin1"*.
1. Uncomment the *INSTALL_EXTRA_TABLES* line and make it equal to *yes*.
1. Uncomment the *INSTALL_PRESENCE_TABLES* line and make it equal to *yes*.
1. Uncomment the *INSTALL_DBUID_TABLES* line and make it equal to *yes*.
1. Drop down near the bottom of the file and uncomment the *PID_FILE* line.
1. Hit `ctrl + o` and hit ‘enter’.
1. Hit `ctrl + x` to exit.

The edited *kamctlrc* file will look like as follows(Note that we have omitted the comments for simplicity)

```c++
SIP_DOMAIN=<your IP address>
DBENGINE=MYSQL
DBRWUSER="kamailio"
DBRWPW="password of your choice"
DBROUSER="kamailioro"
DBROPW="password of your choice"
DBACCESSHOST=<your IP address>
CHARSET="latin1"
INSTALL_EXTRA_TABLES=yes
INSTALL_PRESENCE_TABLES=yes
INSTALL_DBUID_TABLES=yes
PID_FILE=/var/run/kamailio/kamailio.pid
```
Then, edit the *kamailio.cfg* file as follows.

##### Configuring kamailio.cfg

Edit the *kamalio.cfg* file located on the `/etc/kamailio` folder.

```sh
>> nano -w /etc/kamailio/kamalio.cfg
```

Make the top of the file look as below (in nano you can simply copy and paste the following configuration using `ctrl`+`shift`+`v`)

```sh
#!KAMAILIO
#!define WITH_MYSQL
#!define WITH_AUTH
#!define WITH_USRLOCDB
#!define WITH_ANTIFLOOD
#!define WITH_PRESENCE
#!define WITH_ACCDB
```
- Next, find the line: *#!define DBURL “mysql://kamailio:**kamailiorw**@localhost/kamailio”* and Change the **kamailiorw** entry to the password you entered in step 4 in the previous section.

- Then, find the line containing the *alias* and change it as `alias=<IP address of the machine>` and uncomment the line.

- Then, find the line containing the *listen* and change it as `listen=udp:<IP address of your machine>:5060` and uncomment the line. (ex: `listen=udp:192.168.1.1:5060`)

- Search for the line containing **friendly-scanner** (this can be done by pressing `F6` and then typing the term and hitting `enter` in nano editor).

- Immediately above that line, cut-and-paste this addition from Fred Posner at AstriCon
```c++
  if($ua =~ "(friendly-scanner|sipvicious|sipcli)") {
    xlog("L_INFO","script kiddies from IP:$si:$sp - $ua n");
    $sht(ipban=>$si) = 1;
    sl_send_reply("200", "OK");
    exit;
  }
  if($au =~ "(=)|(--)|(')|(#)|(%27)|(%24)" and $au != $null) {
    xlog("L_INFO","[R-REQINIT:$ci] sql injection from IP:$si:$sp - $au n");
    $sht(ipban=>$si) = 1;
    exit;
  }
```
- Hit `ctrl + o` and hit ‘enter’.
- Hit `ctrl + x` to exit.

##### Configuring kamailio

Start editing by executing the below command
```sh
>> nano -w /etc/default/kamailio
```
The file should look as follows (again, we have omitted the comments for the sake of simplicity).

```sh
RUN_KAMAILIO=yes
USER=kamailio
GROUP=kamailio
SHM_MEMORY=128
PKG_MEMORY=4
CFGFILE=/etc/kamailio/kamailio.cfg
```

##### Generating the Database

First of all execute the following command to generate the necessary MySQL databases.

```sh
>> kamdbctl create
```
Then, login to the MySQL shell as the root user. (Please make sure to replace the **password** in the following command with your configured password for ~~kamailio user~~ MySQL root user that you have entered under the ```>> sudo mysql_secure_installation``` command)

```sh
>> mysql -u root -ppassword kamailio
```
**Yes! there is no space between 'p' and 'password'**

In the MySQL prompt execute the following commands one by one.

```SQL
>> ALTER TABLE acc ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE acc ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
>> ALTER TABLE acc ADD COLUMN src_ip VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE acc ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE acc ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE acc ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
>> ALTER TABLE missed_calls ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE missed_calls ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
>> ALTER TABLE missed_calls ADD COLUMN src_ip VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE missed_calls ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE missed_calls ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
>> ALTER TABLE missed_calls ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
>> quit
```

####  Running the Server
##### Running the Kamailio Server
To run the Kamailio server just execute the following command in the terminal

```sh
>> sudo systemctl start kamailio
```
You can check the status of your kamailio server using the `status` command as follows.
```sh
>> sudo systemctl status kamailio
```
If everything went OK, you will see a **green-coloured dot** in your terminal. Else, you need to recheck the kamailio configurations you have made in the above steps.

You can add test users to the kamailio server using the following command format.

```sh
>> kamctl add username password
```
Note that whenever the IP address of your machine changes you need to update the relevant configuration with your new IP. Otherwise, the server will not run.

##### Running the Authentication Server

First of all start the Mongo server by running the following command in a separate terminal.

```sh
>> sudo mongod
````
**Remember!** never close this terminal while the server is running, otherwise it will log an error.
Then, clone this repository, `cd` into it and execute the following command.

```sh
>> node app.js
```
If everything went fine, you will see a message "Server Started" in your log!
