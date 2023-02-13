#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo adduser --system --group odoo
sudo passwd odoo --delete
sudo adduser odoo sudo 
sudo usermod --shell /bin/bash odoo

sudo apt-get install -y git python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less fail2ban
sudo pip3 install babel decorator Werkzeug docutils XlsxWriter feedparser greenlet html2text Jinja2 lxml MarkupSafe mock num2words ofxparse passlib psutil psycogreen psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject xlwt xlrd ebaysdk gevent Mako Pillow libpq-dev


sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less less-plugin-clean-css
sudo apt-get install -y node-less
sudo npm install -g rtlcss
sudo npm install -g less
cd /opt
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb

sudo apt --fix-broken install -y

cd
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf


#install postgresql
sudo apt-get install -y curl ca-certificates gnupg
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
sudo apt-get install -y postgresql-10

sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true


#install odoo 11
cd 
cd /opt
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch 11.0 --single-branch 
cd
cd /opt/odoo
sudo pip3 install -r requirements.txt
cd
sudo pip3 install -r requirements.txt --upgrade
sudo pip3 install sos
sudo pip3 install rust
sudo pip3 install PyPDF2
sudo pip3 install passlib
sudo pip3 install babel
sudo pip3 install werkzeug
sudo pip3 install lxml
sudo pip3 install decorator
sudo pip install psycopg2-binary
sudo python3 -m pip uninstall -y werkzeug
sudo python3 -m pip install werkzeug==0.16.0
sudo pip3 install psutil
sudo pip3 install reportlab
sudo pip3 install html2text
sudo pip3 install docutils
sudo pip3 install num2words
sudo pip3 install suds-jurko
sudo pip3 install ofxparse
sudo pip install phonenumbers



cd /opt
sudo git clone --branch=11.0 <add URL here> --single-branch 
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
sudo tail -f /var/log/odoo/odoo.log

echo "Restoring database from dump"
#Keep dump file in the aame folder with name as dump.sql

sudo chown odoo: /home/ubuntu/dump.sql
sudo su - odoo -c 'createdb  database-name';
sudo su - odoo -c 'psql database-name < /home/ubuntu/dump.sql'
sudo systemctl restart odoo-server

echo "Database restore process completed"





