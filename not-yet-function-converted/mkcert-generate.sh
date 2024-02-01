#!/bin/bash
# input example - /var/www/html/your-project/test
local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
echo "Local IP Address: $local_ip"
read -p "Enter the project certificates path: " certificate_path
rm -r "$certificate_path"
mkdir "$certificate_path"
mkcert -uninstall
cd $(mkcert -CAROOT)
sudo rm -r *
mkcert -install
cd "$certificate_path"
mkcert -cert-file server.crt -key-file private.key localhost $local_ip
echo "SSL certificates generated successfully for $certificate_path"