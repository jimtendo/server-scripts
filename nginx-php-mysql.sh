# Create swap (composer takes up a lot of memory)
fallocate -l 1G /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile   none    swap    sw    0   0' >> /etc/fstab

# Update repos
apt-get update

# Install common necessities
apt-get install -y git-core subversion

# Install Nginx
apt-get install -y nginx

# Install MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password $1'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $1'
apt-get install -y mysql-server

# Install PHP
apt-get install -y php5-fpm php5-mysql php5-cli php5-curl php5-mcrypt php5-gd

# Enable MCrypt
ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/fpm/conf.d/20-mcrypt.ini

# Make /var/www directory
mkdir /var/www

# Configure our site's Nginx Config
cat <<EOF > /etc/nginx/sites-available/default

server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /var/www;
    index index.php index.html index.htm;

    server_name server_domain_name_or_IP;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /var/www;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}

EOF

# Restart shit
service nginx restart