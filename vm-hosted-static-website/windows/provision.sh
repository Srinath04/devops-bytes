apt update
apt install -y nginx
##Start nginx webserver
#sudo systemctl start nginx

## unlink default
rm /etc/nginx/sites-enabled/default
#unlink /etc/nginx/sites-enableddefault/default

## create the nginx config file
touch /etc/nginx/conf.d/samploc.webcontent.conf
## Check the configured file is error free
#nginx -t

##Create the website directory
sudo mkdir -p /var/www/sampweb.local

## Nginx index file load from local to vagrant vm -> nginx web server
sudo cp /vagrant/webcontent/* /var/www/sampweb.local/

##Copy config file
sudo cp /vagrant/samploc.webcontent.conf /etc/nginx/conf.d/

##Reload nginx
sudo systemctl reload nginx

##Message
echo "Custom Machine provisioned at $(date)! Welcome!"
