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

## Note
After Successful Installation without error
Vistit http://host-or-ip/phpnuxbill/install 
Replace [host-or-ip] with your ip address or hostname
You may wish to move the files to root folder, so that you can access nuxbill directly without sub-folder e.g http://host-or-ip/install
```
sudo mv /var/www/html/phpnuxbill/* /var/www/html
```
Make sure you do the above before running final installaton of phpnuxbill e.g http://host-or-ip/install


## Tested
This shell script is tested successfully on

- **Ubuntu 24.04  LTS**
- **Ubuntu 22.04  LTS**
- **Ubuntu 20.04  LTS**
- **Ubuntu 18.04  LTS**

