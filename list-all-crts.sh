#!/bin/bash

# Function to display script usage
usage() {
    echo "Usage: $0 [-lc|--list-certificates [<directory>]] [-mi|--mkcert-install] [-mu|--mkcert-uninstall] [-gca|--generate-ca] [-ica|--install-ca] [-gcrt|--generate-certificate] [-cuc|--check-used-certificate] [-cvh|--create-virtual-host] [-v|--view [<directory>]] [--clear]"
    exit 1
}

get_openssl_certs_dir() {
    # Get the OPENSSLDIR using openssl version
    local openssl_dir=$(openssl version -d | awk -F\" '{print $(NF-1)}')

    # Change to the 'certs' subdirectory
    cd "$openssl_dir/certs" || exit 1

    # Find the actual directory 'certs' points to
    local certs_actual_dir=$(readlink -f .)

    # Print the result
    echo "$certs_actual_dir"
}

list_certificates() {
    local certs_dir="$1"
    local list_flag="$2"

    # Loop through all files in the directory
    for cert_file in "$certs_dir"/*; do
        # Use openssl to print the subject of each certificate
        subject=$(openssl x509 -noout -subject -in "$cert_file" 2>/dev/null)

        # Check if the certificate is valid and the subject is not empty
        if [ -n "$subject" ]; then
            echo "Certificate: $cert_file"
            echo "Subject: $subject"
            echo "----------------------------------"
        fi
    done
}

install_mkcert() {
    local mkcert_version="v1.4.3"
    local mkcert_url="https://github.com/FiloSottile/mkcert/releases/download/$mkcert_version/mkcert-$mkcert_version-linux-amd64"

    wget "$mkcert_url" -O mkcert
    chmod +x mkcert
    sudo mv mkcert /usr/local/bin/
    sudo apt-get install -y libnss3-tools
    mkcert -install
}

uninstall_mkcert() {
    mkcert -uninstall
    sudo rm -r /usr/local/bin/mkcert
    echo "Uninstalled mkcert"
}

generate_ca() {
    echo "Generating CA files..."
    mkdir -p ca
    cd ca

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
    # sudo chown -R $(whoami) ../ca
    
    sudo chown $(whoami) rootCA-key.pem 
    sudo chown $(whoami) rootCA.pem
    echo "Generated CA files in the 'ca' directory"
}

install_ca() {
    echo "Installing CA files..."
    cadir="ca"
    echo "CA directory: $cadir"
    cd "$cadir" || exit 1
    sudo cp rootCA.pem /usr/local/share/ca-certificates/
    sudo update-ca-certificates --fresh

    certfile="rootCA.pem"
    certname="My Root CA"

    # For cert8 (legacy - DBM)
    for certDB in $(find ~/ -name "cert8.db")
    do
        certdir=$(dirname "${certDB}")
        certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i "${certfile}" -d "dbm:${certdir}"
    done

    # For cert9 (SQL)
    for certDB in $(find ~/ -name "cert9.db")
    do
        certdir=$(dirname "${certDB}")
        certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i "${certfile}" -d "sql:${certdir}"
    done
}

check_used_certificate() {
    echo "Checking used certificate..."
    echo "Enter the host and port (e.g., gerganov.com:443):"
    read -r host_port
    openssl s_client -showcerts -connect "$host_port"
}

create_apache_virtual_host() {
    local local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
    echo "Local IP Address: $local_ip"

    read -p "Apache site-enabled path : " apache_dir
    read -p "Filename of Apache config : " filename
    read -p "Enter the project backend path: " backend_path
    read -p "Enter the project crt path: " crt_path
    read -p "Enter the project key path: " key_path

    # Set default values if variables are empty
    apache_dir=${apache_dir:-"/etc/apache2/sites-available/"}
    filename=${filename:-"yourproject.conf"}
    backend_path=${backend_path:-"/var/www/html/smart-office/backend/public"}
    crt_path=${crt_path:-"/var/www/html/smart-office/test/server.crt"}
    key_path=${key_path:-"/var/www/html/smart-office/test/private.key"}

    # Check if the directory exists
    if [ ! -d "$apache_dir" ]; then
        echo "Error: $apache_dir directory does not exist."
        exit 1
    fi

    cd "$apache_dir" || exit 1

    sudo cat <<EOF > "$filename"
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

    echo "Created Apache configuration: $apache_dir/$filename"

    sudo a2enmod ssl
    sudo a2dissite *
    sudo a2ensite "$filename"
    sudo systemctl restart apache2
}

generate_certificate() {
    if [ "$#" -ne 2 ]; then
        echo "Error: Please provide the CA certificate file and key file as parameters."
        return 1
    fi

    local ca_cert="$1"
    local ca_key="$2"
    crt_dir="crt"

    if [ ! -f "$ca_cert" ]; then
        echo "Error: CA certificate file '$ca_cert' not found."
        return 1
    fi

    # Check if CA key file exists
    if [ ! -f "$ca_key" ]; then
        echo "Error: CA key file '$ca_key' not found."
        return 1
    fi

    ca_cert="../$ca_cert"
    ca_key="../$ca_key"

    
    echo "CRT directory: $crt_dir\n"
    mkdir -p "$crt_dir"
    cd "$crt_dir" || exit 1

    

    

    local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)

    # Generate a new private key
    openssl genpkey -algorithm RSA -out private.key

    # Create a configuration file for the CSR
    cat <<EOF > crt.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = BD
ST = Dhaka
L = Gulshan
O = YourCompany2
OU = YourDepartment2
CN = localhost

[v3_req]
basicConstraints = CA:FALSE
subjectAltName = DNS:localhost,IP:$local_ip
EOF

    # Create a CSR with the subjectAltName extension
    openssl req -new -key private.key -out server.csr -config crt.conf

    # Sign the CSR with the provided CA
    openssl x509 -req -in server.csr -CA "$ca_cert" -CAkey "$ca_key" -CAcreateserial -out server.crt -days 3650 -extensions v3_req -extfile crt.conf
}

view_certificate() {
    local cert_file="$1"

    if [ ! -e "$cert_file" ]; then
        echo "Error: Certificate file does not exist at: $cert_file"
        return 1
    fi

    openssl x509 -in "$cert_file" -text -noout
}

clear_directories() {
    echo "Clearing directories..."
    rm -rf ca certificates output crt
    echo "Directories cleared."
}

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    usage
fi

# Initialize flags
list_flag=0
mkcert_install_flag=0
mkcert_uninstall_flag=0
generate_ca_flag=0
install_ca_flag=0
check_used_certificate_flag=0
create_apache_virtual_host_flag=0
clear_flag=0
generate_certificate_flag=0
view_certificate_flag=0
certs_dir=""
cert_to_view=""

# Check for options
while [ "$#" -gt 0 ]; do
    case "$1" in
        -lc|--list-certificates|--list-certificates)
            list_flag=1
            shift
            if [ "$#" -gt 0 ] && [[ ! "$1" =~ ^- ]]; then
                certs_dir="$1"
                shift
            else
                certs_dir=$(get_openssl_certs_dir)
            fi
            ;;
        -mi|--mkcert-install)
            mkcert_install_flag=1
            shift
            ;;
        -mu|--mkcert-uninstall)
            mkcert_uninstall_flag=1
            shift
            ;;
        -gca|--generate-ca)
            generate_ca_flag=1
            shift
            ;;
        -ica|--install-ca)
            install_ca_flag=1
            shift
            ;;
        -cuc|--check-used-certificate)
            check_used_certificate_flag=1
            shift
            ;;
        -cvh|--create-virtual-host)
            create_apache_virtual_host_flag=1
            shift
            ;;
        -gcrt|--generate-certificate)
            generate_certificate_flag=1
            shift
            ;;
        -v|--view)
            view_certificate_flag=1
            shift
            if [ "$#" -gt 0 ] && [[ ! "$1" =~ ^- ]]; then
                cert_to_view="$1"
                shift
            else
                echo "Error: Please provide the file path to the certificate for viewing."
                exit 1
            fi
            ;;
        --clear)
            clear_flag=1
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ "$list_flag" -eq 1 ]; then
    list_certificates "$certs_dir" "$list_flag"
fi

if [ "$mkcert_uninstall_flag" -eq 1 ]; then
    uninstall_mkcert
    exit 0
fi

if [ "$mkcert_install_flag" -eq 1 ]; then
    install_mkcert
    exit 0
fi

if [ "$generate_ca_flag" -eq 1 ]; then
    generate_ca
    exit 0
fi

if [ "$install_ca_flag" -eq 1 ]; then
    install_ca
    exit 0
fi

if [ "$check_used_certificate_flag" -eq 1 ]; then
    check_used_certificate
    exit 0
fi

if [ "$create_apache_virtual_host_flag" -eq 1 ]; then
    create_apache_virtual_host
    exit 0
fi

if [ "$generate_certificate_flag" -eq 1 ]; then
    generate_certificate "ca/rootCA.pem" "ca/rootCA-key.pem"
    exit 0
fi

if [ "$view_certificate_flag" -eq 1 ]; then
    view_certificate "$cert_to_view"
    exit 0
fi

if [ "$clear_flag" -eq 1 ]; then
    clear_directories
    exit 0
fi
