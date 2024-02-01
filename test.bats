#!/usr/bin/env bats

# Load the script
load "$(pwd)/smcert.sh"


# Mocking function to simulate user input
input_mock() {
  echo "$1"
}

# Helper function to create a temporary directory
setup() {
  TEMP_DIR=$(mktemp -d)
  trap cleanup EXIT
}

# Helper function to cleanup temporary directory
cleanup() {
  rm -rf "$TEMP_DIR"
}

# Test for Get OpenSSL certs directory function
@test "Get OpenSSL certs directory" {
  run get_openssl_certs_dir

  [ "$status" -eq 0 ]

  # Check if the output is not empty and points to a valid directory
  [ -n "$output" ]
  [ -d "$output" ]
}

# Test for list_certificates function
@test "List certificates in the OpenSSL directory" {
  local certs_dir
  certs_dir=$(get_openssl_certs_dir)

  run list_certificates "$certs_dir" 1

  [ "$status" -eq 0 ]

  [[ "$output" == *"Certificate: $certs_dir/"*".pem"* ]]
  [[ "$output" == *"$certs_dir/"*".pem"* ]]
  [[ "$output" == *"----------------------------------"* ]]
}

# Test for install_mkcert function
@test "Install mkcert" {
  run install_mkcert

  [ "$status" -eq 0 ]

  # Check if the output contains the expected string
  [[ "$output" == *"‘mkcert’ saved"* ]]
  [[ "$output" == *"The local CA is now installed in the system trust store!"* ]]
  [[ "$output" == *"The local CA is now installed in the Firefox and/or Chrome/Chromium trust store (requires browser restart)!"* ]]

  # Check if the mkcert binary is installed in /usr/local/bin/
  [ -x "/usr/local/bin/mkcert" ]

  # Check if libnss3-tools is installed
  dpkg -s libnss3-tools &> /dev/null
}


# Test for uninstall_mkcert function
@test "Uninstall mkcert" {
  run uninstall_mkcert

  [ "$status" -eq 0 ]

  # Check if the output contains the expected string
  [[ "$output" == *"Uninstalled mkcert"* ]]

  # Check if the mkcert binary is not present in /usr/local/bin/
  [ ! -x "/usr/local/bin/mkcert" ]
}

# Test for generate_ca function
@test "Generate CA" {
  run generate_ca

  [ "$status" -eq 0 ]
  [ -d "ca" ]
  [ -f "ca/rootCA-key.pem" ]
  [ -f "ca/rootCA.pem" ]
  [ -f "ca/ca.conf" ]
}

# Test for install_ca function
@test "Install CA" {
  run install_ca

  [ "$status" -eq 0 ]
  [ -d "/usr/local/share/ca-certificates" ]
}

# Test for check_used_certificate function
@test "Check used certificate" {
  run check_used_certificate "127.0.0.1:443"

  [ "$status" -eq 0 ]
  [ -n "$output" ]  # Check if there is any output
  [[ "$output" == *"Checking used certificate"* ]]
  [[ "$output" == *"closed"* ]]
}

# Test for create_apache_virtual_host function
@test "Create Apache virtual host" {
  # run create_apache_virtual_host "yourproject.conf" "/var/www/html/smart-office/backend/public" "/var/www/html/smart-office/test/server.crt" "/var/www/html/smart-office/test/private.key"
  run create_apache_virtual_host "" "" "" ""

  server_root=$(apachectl -S | awk '/ServerRoot/ {print $NF}' | sed 's/"//g')
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"Created Apache configuration: $server_root/sites-available/yourproject.conf"* ]]
  [ -f "$server_root/sites-available/yourproject.conf" ]
}

# Test for generate_certificate function
@test "Generate certificate" {
  run generate_certificate "ca/rootCA.pem" "ca/rootCA-key.pem"

  echo "Output: $output"
  echo "Error: $error"

  [ "$status" -eq 0 ]
  [ -f "crt/server.crt" ]
  [ -f "crt/private.key" ]
  [ -f "crt/crt.conf" ]
}

# Test for view_certificate function
@test "View certificate" {
  local cert_file="crt/server.crt"

  run view_certificate "$cert_file"

  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

# Test for clear_directories function
@test "Clear directories" {
  run clear_directories

  [ "$status" -eq 0 ]
  [ ! -d "$TEMP_DIR/ca" ]
  [ ! -d "$TEMP_DIR/certificates" ]
  [ ! -d "$TEMP_DIR/output" ]
  [ ! -d "$TEMP_DIR/crt" ]
}
