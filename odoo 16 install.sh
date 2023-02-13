#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
#sudo adduser --system --home=/opt/odoo --group odoo
sudo adduser --system --group odoo
sudo passwd odoo --delete
sudo adduser odoo sudo 
sudo usermod --shell /bin/bash odoo
#sudo apt-get install -y python3-pip
#sudo apt-get install -y python-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev
#sudo apt-get install -y git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev gdebi -y
#sudo apt-get install -y libpq-dev python-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libffi-dev
sudo apt-get install -y openssh-server fail2ban #to prevent attacks
sudo apt-get install -y python3-pip git
sudo apt-get install -y python-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev



sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less	 less-plugin-clean-css
sudo apt-get install -y node-less
sudo npm install -g rtlcss
cd /opt
sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb
sudo dpkg -i wkhtmltox_0.12.6-1.focal_amd64.deb
#sudo apt-get install -y xfonts-75dpi
#sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb
#sudo dpkg -i wkhtmltox_0.12.6-1.bionic_amd64.deb
sudo apt --fix-broken install -y

cd
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf

#sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
#sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
#sudo apt install -y fontconfig
#sudo apt install -y xfonts-75dpi
#sudo apt --fix-broken install -y
#dpkg -l wkhtmltopdf
#\q
#dpkg -l wkhtmltox
#\q


#install postgresql
sudo apt-get install curl ca-certificates gnupg
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
sudo apt-get install -y postgresql-13
#sudo passwd postgres --delete
#sudo su - postgres 
#createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt odoo
#psql -U postgres -c 'ALTER USER odoo WITH SUPERUSER';
#\q
sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true


#install odoo 15
#sudo su - odoo -s /bin/bash
cd 
#cd /opt/odoo
cd /opt
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 --single-branch 
cd
cd /opt/odoo
sudo pip3 install -r requirements.txt
cd
cd /opt
sudo git clone --branch=16.0 https://shahnoor:Yk92hwgayBZk8Hge-Hht@git.bistasolutions.com/bistasolutions/odoo_enterprise.git --single-branch 
ls -l
sudo chown -R odoo: /opt/odoo_enterprise/
sudo chown -R odoo: /opt/odoo/

ls -l
cd
#logfile creation
sudo mkdir /var/log/odoo
sudo chown odoo:root /var/log/odoo
#configuring odoo.conf file
sudo touch /etc/odoo.conf
sudo cat <<EOT > /etc/odoo.conf
[options]
   ; This is the password that allows database operations:
   ; admin_passwd = admin
   db_host = False
   db_port = False
   db_user = odoo
   db_password = False
   addons_path = /opt/odoo_enterprise,/opt/odoo/addons
   logfile = /var/log/odoo/odoo.log
EOT

sudo chown odoo: /etc/odoo.conf
sudo chmod 640 /etc/odoo.conf


#configuring service file
sudo touch /lib/systemd/system/odoo-server.service
sudo cat <<EOT > /lib/systemd/system/odoo-server.service
[Unit]
Description=Odoo Open Source ERP and CRM
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
PermissionsStartOnly=true
SyslogIdentifier=odoo-server
User=odoo
Group=odoo
ExecStart=/opt/odoo/odoo-bin --config=/etc/odoo.conf
WorkingDirectory=/opt/odoo/
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOT




sudo chmod 755 /lib/systemd/system/odoo-server.service
sudo chown root: /lib/systemd/system/odoo-server.service
sudo systemctl daemon-reload
sudo systemctl start odoo-server
sudo systemctl enable odoo-server
cd

#install nginx

sudo apt update
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo unlink /etc/nginx/sites-enabled/default
cd /etc/nginx/sites-available/
sudo wget https://odoo-nginx.s3.amazonaws.com/odoo-http.conf
sudo ln -s /etc/nginx/sites-available/odoo-http.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo nginx -s reload


sudo tail -f /var/log/odoo/odoo.log


