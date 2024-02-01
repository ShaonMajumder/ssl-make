# ./mkcert-generate-ca-only.sh
./smcert.sh
pkill -f "yarn start-linux"
cd /var/www/html/smart-office/
./server.sh