#!/bin/bash

echo "

####################################################################
#                                                                  #
#  Welcome to the LAMP, FreeRADIUS, and PHPNuxBill installation    #
#                                                                  #
#  This script will guide you through the installation and         #
#  configuration of the following components:                      #
#                                                                  #
#  - LAMP stack (Linux, Apache, MySQL/MariaDB, PHP)                #
#  - FreeRADIUS for authentication and authorization               #
#  - PHPNuxBill for billing and network management                 #
#                                                                  #
#  The script will prompt you to choose between MySQL or           #
#  MariaDB as the database server, and it will securely            #
#  configure the MySQL/MariaDB credentials for FreeRADIUS.         #
#                                                                  #
#  After the installation, the script will restart Apache to       #
#  ensure all changes take effect.                                 #
#                                                                  #
#  Donate: https://paypal.me/focuslinkstech                        #
#  Support: https://t.me/focuslinkstech                            #
#                                                                  #
####################################################################
"
sleep 5

# Update & Upgrade
read -r -p "Do you want to update this system [y/n]? " update
if [[ $update =~ ^[Yy]$ ]]; then
    sudo apt-get update -y
    read -r -p "Do you want to upgrade this system [y/n]? " upgrade
    if [[ $upgrade =~ ^[Yy]$ ]]; then
        sudo apt-get upgrade -y
    fi
fi

# Install additional modules
read -r -p "Install wget, curl, git, zip, unzip [y/n]? " modules
if [[ $modules =~ ^[Yy]$ ]]; then
    sudo apt-get install -y wget curl git zip unzip
fi

# Install Database
read -r -p "Install Database [y/n]? " sql
if [[ $sql =~ ^[Yy]$ ]]; then
    # Choose your database server
    echo "Choose your database server:"
    select db_server in "MySQL" "MariaDB"; do
        case $db_server in
        "MySQL")
            sudo apt-get install -y mysql-server mysql-client
            sudo mysql_secure_installation

            # Make MySQL connectable from outside world without SSH tunnel
            echo ''
            read -r -p "Enable remote access for MySQL [y/n]? " remotemysql
            if [[ $remotemysql =~ ^[Yy]$ ]]; then
                if [ -z $1 ]; then
                    echo ''
                    read -rsp "Confirm MySQL root password: " pswd
                else
                    pswd=$1
                fi
                if [ -z $pswd ]; then
                    echo "Password is required!"
                    exit 1
                else
                    # Enable remote access
                    sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

                    # Adding grant privileges to MySQL root user from everywhere
                    MYSQL='mysql'
                    Q1="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$pswd' WITH GRANT OPTION;"
                    Q2="FLUSH PRIVILEGES;"
                    Q3="UPDATE mysql.user SET plugin='' WHERE user='root';"
                    Q4="FLUSH PRIVILEGES;"
                    SQL="${Q1}${Q2}${Q3}${Q4}"

                    sudo $MYSQL -uroot -p"$pswd" -e "$SQL"

                    # Restart MySQL
                    sudo systemctl restart mysql
                    sudo systemctl enable mysql
                fi
            fi
            echo ">>> Finished Installing MySQL <<<"
            sleep 2
            echo
            break
            ;;
        "MariaDB")
            sudo apt-get install -y mariadb-server mariadb-client
            sudo mysql_secure_installation

            # Make MariaDB connectable from outside world without SSH tunnel
            echo ''
            read -r -p "Enable remote access for MariaDB [y/n]? " remotemysql
            if [[ $remotemysql =~ ^[Yy]$ ]]; then
                if [ -z $1 ]; then
                    echo ''
                    read -rsp "Confirm MariaDB root password: " pswd
                else
                    pswd=$1
                fi
                if [ -z $pswd ]; then
                    echo "Password is required!"
                    exit 1
                else
                    # Enable remote access
                    sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

                    # Adding grant privileges to MariaDB root user from everywhere
                    MYSQL='mysql'
                    Q1="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$pswd' WITH GRANT OPTION;"
                    Q2="FLUSH PRIVILEGES;"
                    Q3="UPDATE mysql.user SET plugin='' WHERE user='root';"
                    Q4="FLUSH PRIVILEGES;"
                    SQL="${Q1}${Q2}${Q3}${Q4}"

                    sudo $MYSQL -uroot -p"$pswd" -e "$SQL"

                    # Restart MariaDB
                    sudo systemctl restart mariadb
                    sudo systemctl enable mariadb
                fi
            fi
            echo ">>> Finished Installing MariaDB <<<"
            sleep 2
            echo
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
        esac
    done
    # Create new database and user
    read -r -p "Do you want to create a new database and user [y/n]? " create_db_user
    if [[ $create_db_user =~ ^[Yy]$ ]]; then
        read -r -p "Enter new database name: " dbname
        read -r -p "Enter new username: " dbuser
        read -rsp "Enter password for new user: " dbpass
        echo

        MYSQL='mysql'
        SQL="CREATE DATABASE $dbname;
             CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
             GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
             FLUSH PRIVILEGES;"

        sudo $MYSQL -uroot -p"$pswd" -e "$SQL"
        echo "Database '$dbname' and user '$dbuser' created successfully!"
        sleep 2
    fi
fi

# Install Webserver
read -r -p "Install Webserver (Apache2 & PHP) [y/n]? " webserver
if [[ $webserver =~ ^[Yy]$ ]]; then
    echo ">>> Installing WebServer <<<"
    sudo apt-get install -y apache2 php php-curl php-mbstring php-xml php-gd php-dev php-pear php-ssh2 libmcrypt-dev mcrypt make php-json php-bcmath php-intl php-mysql php-ldap php-zip php-soap php-imap php-memcached php-redis php-apcu
    sleep 2
    echo ">>> Finished Installing WebServer <<<"
    sleep 2
fi

# PHPNuxBill Installation Start From Here
echo "Choose What To Install?"
echo "  1) PHPNuxBill Only"
echo "  2) FreeRADIUS Only"
echo "  3) PHPNuxBill + FreeRADIUS"
echo
MYSQL='mysql'
read -r n
case $n in
1)
    # Install PHPNuxBill
    echo "Installing PHPNuxBill..."
    git clone https://github.com/hotspotbilling/phpnuxbill.git
    sudo mv phpnuxbill /var/www/html/
    sudo chown -R www-data:www-data /var/www/html/phpnuxbill
    sudo chmod -R 755 /var/www/html/phpnuxbill
    sleep 2
    echo ">>> Finished Installing PHPNuxBill <<<"
    sleep 2
    ;;
2)
    # Install FreeRADIUS
    echo ">>> Installing FreeRADIUS Server <<<"
    sleep 2
    sudo apt-get install -y freeradius freeradius-mysql freeradius-utils
    sleep 2
    echo ">>> Configuring FreeRADIUS Server <<<"
    # Check the FreeRADIUS configuration directory
    if [ -d "/etc/freeradius/3.0" ]; then
        freeradius_config_dir="/etc/freeradius/3.0"
    else
        freeradius_config_dir="/etc/freeradius"
    fi

    # Configure FreeRADIUS to use the MySQL credentials and other neccessary configurations
    cd "$freeradius_config_dir/mods-enabled"
    sudo ln -s ../mods-available/sql sql
    sudo ln -s ../mods-available/sqlcounter sqlcounter
    cd
    # sudo ln -s "$freeradius_config_dir/mods-available/sql" "$freeradius_config_dir/mods-enabled/"
    sudo mv $freeradius_config_dir/sites-available/default $freeradius_config_dir/sites-available/default.back
    sudo cp ~/freeradius-config/config-files/default $freeradius_config_dir/sites-available/default
    sudo mv $freeradius_config_dir/sites-available/inner-tunnel $freeradius_config_dir/sites-available/inner-tunnel.back
    sudo cp ~/freeradius-config/config-files/inner-tunnel $freeradius_config_dir/sites-available/default
    sudo mv $freeradius_config_dir/mods-available/sql $freeradius_config_dir/mods-available/sql.back
    sudo cp ~/freeradius-config/config-files/sql $freeradius_config_dir/mods-available/sql
    sudo mv $freeradius_config_dir/mods-available/sqlcounter $freeradius_config_dir/mods-available/sqlcounter.back
    sudo cp ~/freeradius-config/config-files/sqlcounter $freeradius_config_dir/mods-available/sqlcounter
    sudo cp -r ~/freeradius-config/config-files/mysql/* $freeradius_config_dir/mods-config/sql/counter/mysql/
    sudo sed -i 's|driver = "rlm_sql_null"|driver = "rlm_sql_mysql"|' "$freeradius_config_dir/mods-available/sql"
    sudo sed -Ei '/^[\t\s#]*tls\s+\{/, /[\t\s#]*\}/ s/^/#/' "$freeradius_config_dir/mods-available/sql"
    sudo sed -i 's|login = ""|login = '"$dbuser"'|' "$freeradius_config_dir/mods-available/sql"
    sudo sed -i 's|password = ""|password = '"$dbpass"'|' "$freeradius_config_dir/mods-available/sql"
    sudo sed -i 's|radius_db = ""|radius_db = '"$dbname"'|' "$freeradius_config_dir/mods-available/sql"
    sudo $MYSQL -u"$dbuser" -p"$dbpass" "$dbname" < "$freeradius_config_dir/mods-config/sql/main/mysql/schema.sql"


    # Start FreeRADIUS
    sudo chgrp -h freerad $freeradius_config_dir/mods-enabled/sql
    sudo chgrp -h freerad $freeradius_config_dir/mods-enabled/sqlcounter
    sudo chgrp -h freerad $freeradius_config_dir/mods-enabled/sql
    sudo chgrp -h freerad $freeradius_config_dir/mods-config/sql/counter/mysql
    sudo systemctl enable freeradius
    sudo systemctl start freeradius
    sleep 2
    echo ">>> Finished Installing FreeRADIUS Server"
    sleep 2
    ;;
3)
    # Install PHPNuxBill
    echo ">>> Installing PHPNuxBill <<<"
    sleep 2
    sudo apt-get install -y git
    git clone https://github.com/hotspotbilling/phpnuxbill.git
    sudo mv phpnuxbill /var/www/html/
    sudo chown -R www-data:www-data /var/www/html/phpnuxbill
    sudo chmod -R 755 /var/www/html/phpnuxbill

    # Install FreeRADIUS
    echo ">>> Installing FreeRADIUS Server <<<"
    sudo apt-get install -y freeradius freeradius-mysql freeradius-utils
    sleep 2
    echo ">>> Configuring FreeRADIUS Server <<<"
    # Check the FreeRADIUS configuration directory
    if [ -d "/etc/freeradius/3.0" ]; then
        freeradius_config_dir="/etc/freeradius/3.0"
    else
        freeradius_config_dir="/etc/freeradius"
    fi

    # Configure FreeRADIUS to use the MySQL credentials and other neccessary configurations
    cd "$freeradius_config_dir/mods-enabled"
    sudo ln -s ../mods-available/sql sql
    sudo ln -s ../mods-available/sqlcounter sqlcounter
    cd
    # sudo ln -s "$freeradius_config_dir/mods-available/sql" "$freeradius_config_dir/mods-enabled/"
    sudo mv $freeradius_config_dir/sites-available/default $freeradius_config_dir/sites-available/default.back
    sudo cp ~/freeradius-config/config-files/default $freeradius_config_dir/sites-available/default
    sudo mv $freeradius_config_dir/sites-available/inner-tunnel $freeradius_config_dir/sites-available/inner-tunnel.back
    sudo cp ~/freeradius-config/config-files/inner-tunnel $freeradius_config_dir/sites-available/default
    sudo mv $freeradius_config_dir/mods-available/sql $freeradius_config_dir/mods-available/sql.back
    sudo cp ~/freeradius-config/config-files/sql $freeradius_config_dir/mods-available/sql
    sudo mv $freeradius_config_dir/mods-available/sqlcounter $freeradius_config_dir/mods-available/sqlcounter.back
    sudo cp ~/freeradius-config/config-files/sqlcounter $freeradius_config_dir/mods-available/sqlcounter
    sudo cp -r ~/freeradius-config/config-files/mysql/* $freeradius_config_dir/mods-config/sql/counter/mysql/
    sudo sed -i 's|driver = "rlm_sql_null"|driver = "rlm_sql_mysql"|' "$freeradius_config_dir/mods-available/sql"
    sudo sed -Ei '/^[\t\s#]*tls\s+\{/, /[\t\s#]*\}/ s/^/#/' "$freeradius_config_dir/mods-available/sql"
    sudo sed -i 's|login = ""|login = '"$dbuser"'|' "$freeradius_config_dir/mods-available/sql"
    sudo sed -i 's|password = ""|password = '"$dbpass"'|' "$freeradius_config_dir/mods-available/sql"
    sudo sed -i 's|radius_db = ""|radius_db = '"$dbname"'|' "$freeradius_config_dir/mods-available/sql"
    sudo $MYSQL -u"$dbuser" -p"$dbpass" "$dbname" < "$freeradius_config_dir/mods-config/sql/main/mysql/schema.sql"

    # Start FreeRADIUS
    sudo chgrp -h freerad $freeradius_config_dir/mods-enabled/sql
    sudo chgrp -h freerad $freeradius_config_dir/mods-enabled/sqlcounter
    sudo chgrp -h freerad $freeradius_config_dir/mods-enabled/sql
    sudo systemctl enable freeradius
    sudo systemctl start freeradius
    sleep 2
    echo ">>> Finished Installing FreeRADIUS Server and PHPNuxBill <<<"
    ;;
esac

# Restart Apache
echo ">>> Restarting Apache"
sudo systemctl enable apache2
sudo systemctl restart apache2
echo ">>> Finished Restarting Apache <<<"
sleep 2

# Restart MariaDB or MySQL
echo ">>> Restarting Database"
sudo systemctl stop $MYSQL
sudo systemctl enable $MYSQL
sudo systemctl start $MYSQL
echo ">>> Finished Restarting $db_server <<<"
sleep 2

# Restart FreeRADIUS
echo ">>> Restarting FreeRADIUS"
sudo systemctl stop freeradius
sudo pkill -f radius
sudo systemctl enable freeradius
sudo systemctl restart freeradius
echo ">>> Finished Restarting FreeRADIUS <<<"

# Display IP Address
echo "
Your server's IP address is: $(hostname -I | awk '{print $2}')

# Display Database Information
- Database Information:
- Host: localhost
- Username: $dbuser
- Password: Your Password
- Database Name: $dbname
- To access PHPNuxBill, visit:
- http://$(hostname -I | awk '{print $2}')/phpnuxbill/install/
"
echo "LAMP (with $db_server), essential PHP extensions, FreeRADIUS, and PHPNuxBill have been installed successfully!"
