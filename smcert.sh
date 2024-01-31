#!/bin/bash
# input example - /var/www/html/your-project/test
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

read -p "Enter the project certificates path: " certificate_path

ca_source_path="$script_dir/ca"
output=$(./generate-ca.sh -cadir "$ca_source_path") 
echo "$output"

cd $script_dir
output=$(./install-ca.sh -cadir "$ca_source_path") 
echo "$output"
cd $script_dir


local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
echo "Local IP Address: $local_ip"


### generating certificate
sudo rm -r "$certificate_path"
mkdir -p "$certificate_path"
cd $script_dir
cp "$ca_source_path"/rootCA.pem "$ca_source_path"/rootCA-key.pem "$certificate_path"


output=$(./generate-certificate.sh -crt_dir "$certificate_path") 
echo "$output"


cd $certificate_path
openssl x509 -in server.crt -text -noout



echo "Restarting Server"
sudo systemctl restart apache2