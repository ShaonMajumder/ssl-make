#!/bin/bash

cadir="default_ca_directory"

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -cadir|--cadir) cadir="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Now you can use the $cadir variable in your script
echo "CA directory: $cadir\n"
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
O  = BYSL Dev
OU = Fintech
CN = localhost
emailAddress = smazoomder@gmail.com

[ v3_req ]
basicConstraints = CA:TRUE
EOF


openssl genpkey -algorithm RSA -out rootCA-key.pem
openssl req -x509 -new -key rootCA-key.pem -out rootCA.pem -days 3650 -config ca.conf

echo "Generated CA Files"