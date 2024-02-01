# ./mkcert-generate-ca-only.sh
./sslcert.sh
pkill -f "yarn start-linux"
cd /var/www/html/smart-office/
./server.sh