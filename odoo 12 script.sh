#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y

sudo adduser --system --group odoo
sudo passwd odoo --delete
sudo adduser odoo sudo 
sudo usermod --shell /bin/bash odoo
sudo apt-get install -y python3-pip python3-ldap python3-psycopg2 fontconfig libjpeg-turbo8 xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils node-less npm git fail2ban
sudo npm install -g less less-plugin-clean-css
cd /opt
sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb
sudo dpkg -i wkhtmltox_0.12.6-1.focal_amd64.deb
sudo apt --fix-broken install -y
ln -s /usr/local/bin/wkhtmltopdf /usr/bin
ln -s /usr/local/bin/wkhtmltoimage /usr/bin

#install postgresql
sudo apt-get install curl ca-certificates gnupg
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
sudo apt-get install -y postgresql-11

sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true


#install odoo 12

cd 
#cd /opt/odoo
cd /opt
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch 12.0 --single-branch 
cd
cd /opt/odoo
sudo pip3 install -r requirements.txt
sudo pip3 install pypdf2 passlib werkzeug lxml
sudo pip install python-dateutil --upgrade
sudo pip install Pillow
sudo python3 -m pip uninstall werkzeug
sudo python3 -m pip install werkzeug==0.16.0
sudo pip3 install psutil reportlab html2text num2words
cd
cd /opt
#add odoo enterprise clone URL below
sudo git clone --branch=12.0 <add URL here> --single-branch 
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

cd
sudo tail -f /var/log/odoo/odoo.log


