# Server_EasyTAlk
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

Then, first edit the *kamctlrc* file located on the `/etc/kamailio` folder. We are using *nano* editor for this tutorial.

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

The edited *kamctlrc* file will look like as follows(Note that we have ommited the comments for simplicity)

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
