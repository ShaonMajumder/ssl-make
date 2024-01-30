#!/bin/bash
# input example - /var/www/html/your-project/test
local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
echo "Local IP Address: $local_ip"

read -p "apache site-enabled path : " apache_dir
read -p "Filename of Apache config : " filename
read -p "Enter the project backend path: " backend_path
read -p "Enter the project crt path: " crt_path
read -p "Enter the project key path: " key_path

# Set default values if apache_dir is empty
if [ -z "$apache_dir" ]; then
    apache_dir="/etc/apache2/sites-available/"
fi

if [ -z "$filename" ]; then
    filename="yourproject.conf"
fi

if [ -z "$backend_path" ]; then
    backend_path="/home/shaon/Projects/smart-office/backend/public"
fi

if [ -z "$crt_path" ]; then
    crt_path="/home/shaon/Projects/smart-office/test/server.crt"
fi

if [ -z "$key_path" ]; then
    key_path="/home/shaon/Projects/smart-office/test/private.key"
fi


# Check if the directory exists
if [ ! -d "$apache_dir" ]; then
    echo "Error: $apache_dir directory does not exist."
    exit 1
fi

cd "$apache_dir" || exit 1





sudo cat <<EOF > $filename

<VirtualHost *:443>
	ServerName $local_ip
    ServerAdmin webmaster@$local_ip
    DocumentRoot $backend_path

    SSLEngine on
	SSLUseStapling off
    SSLCertificateFile $crt_path
    SSLCertificateKeyFile $key_path

	ServerAlias $local_ip

    <Directory "$backend_path">
		Options All
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# echo $apache_dir/*
echo $filename
sudo a2enmod ssl
sudo a2ensite $filename
sudo systemctl restart apache2