mkcert -uninstall
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
mv mkcert-v1.4.3-linux-amd64 mkcert
sudo mv mkcert /usr/local/bin/
sudo chmod +x /usr/local/bin/mkcert
sudo apt-get install libnss3-tools
mkcert -install