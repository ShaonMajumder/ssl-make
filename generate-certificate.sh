crt_dir="default_ca_directory"

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -crt_dir|--crt_dir) crt_dir="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done


echo "CRT directory: $crt_dir\n"
mkdir -p $crt_dir
cd $crt_dir

local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)

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
O = YourCompany2
OU = YourDepartment2
CN = localhost

[v3_req]
basicConstraints = CA:FALSE
subjectAltName = DNS:localhost,IP:$local_ip
EOF

# Create a CSR with the subjectAltName extension
openssl req -new -key private.key -out server.csr -config csr_config.conf

# Sign the CSR with the existing CA
openssl x509 -req -in server.csr -CA "rootCA.pem" -CAkey "rootCA-key.pem" -CAcreateserial -out server.crt -days 3650 -extensions v3_req -extfile csr_config.conf