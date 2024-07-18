# freeradius-config
PHPNuxBill Installation Shell Script, this script will guide you through the installation and configuration of the following components:
- LAMP stack (Linux, Apache, MySQL/MariaDB, PHP)               
* FreeRADIUS for authentication and authorization          
+ PHPNuxBill for billing and network management          

## Install using GIT
```
sudo apt-get install git
```
```
sudo git clone https://github.com/Focuslinkstech/freeradius-config.git
```
```
cd freeradius-config
sudo chmod +x install.sh
sudo ./install.sh
```
## Install using WGET
```
sudo apt-get install wget
```
```
wget https://github.com/Focuslinkstech/freeradius-config/archive/refs/heads/main.zip
unzip *.zip
```
```
sudo mv freeradius-config-main freeradius-config
cd freeradius-config
sudo chmod +x install.sh
sudo ./install.sh
```

