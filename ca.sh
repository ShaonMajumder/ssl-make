#!/bin/bash
cadir="ca"
echo "ca path - $cadir\n"
mkdir -p $cadir
cd $cadir

# creating the CA certificate details
# Check if ca.conf exists before creating it

cat <<EOF > ca.conf
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
C  = BD
ST = Dhaka
L  = Gulshan
O  = BYSL Kalchandpur
OU = Fintech
CN = localhost
emailAddress = smazoomder@gmail.com

[ v3_req ]
basicConstraints = CA:TRUE
EOF


openssl genpkey -algorithm RSA -out rootCA-key.pem
openssl req -x509 -new -key rootCA-key.pem -out rootCA.pem -days 3650 -config ca.conf

echo "Generated CA Files"