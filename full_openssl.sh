#!/bin/bash
# input example - /var/www/html/your-project/test
local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
echo "Local IP Address: $local_ip"
read -p "Enter the project certificates path: " certificate_path



# going to key files of root
# cd $(mkcert -CAROOT)
# sudo rm -r *
# cd "$certificate_path"


### generating certificate
rm -r "$certificate_path"
mkdir "$certificate_path"
cd "$certificate_path"

# creating the CA certificate details
cat <<EOF > openssl-custom.conf
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
C  = BD
ST = Dhaka
L  = Gulshan
O  = SHAON2
OU = Software
CN = localhost
emailAddress = smazoomder@gmail.com

[ v3_req ]
basicConstraints = CA:TRUE
EOF
openssl genpkey -algorithm RSA -out rootCA-key.pem
openssl req -x509 -new -key rootCA-key.pem -out rootCA.pem -days 3650 -config openssl-custom.conf
rm -r openssl-custom.conf














# ### generating certificate
# rm -r "$certificate_path"
# mkdir "$certificate_path"
# cd "$certificate_path"

# Generate a new private key
openssl genpkey -algorithm RSA -out private.key

# Create a configuration file for the CSR
cat <<EOF > csr_config.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = BD
ST = Dhaka
L = Gulshan
O = YourCompany
OU = YourDepartment
CN = localhost

[v3_req]
basicConstraints = CA:FALSE
subjectAltName = DNS:localhost,IP:$local_ip
EOF

# Create a CSR with the subjectAltName extension
openssl req -new -key private.key -out server.csr -config csr_config.conf

# Sign the CSR with the existing CA
openssl x509 -req -in server.csr -CA "rootCA.pem" -CAkey "rootCA-key.pem" -CAcreateserial -out server.crt -days 3650 -extensions v3_req -extfile csr_config.conf


mkcert -uninstall
mkcert -install -cert-file rootCA.pem -key-file rootCA-key.pem


# intalling with custom CA
# mkcert -install -cert-file rootCA.pem -key-file rootCA-key.pem

# rm -r "$certificate_path"
# mkdir "$certificate_path"
# cd "$certificate_path"
# mkcert -cert-file server.crt -key-file private.key localhost $local_ip
openssl x509 -in server.crt -text -noout
echo "Restarting Server"
sudo systemctl restart apache2