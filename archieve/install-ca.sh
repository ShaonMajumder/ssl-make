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

# echo "$PWD"
# return 

# Now you can use the $cadir variable in your script
echo "CA directory: $cadir\n"
cd $cadir
sudo cp rootCA.pem /usr/local/share/ca-certificates/
sudo update-ca-certificates --fresh


### Script installs root.cert.pem to certificate trust store of applications using NSS
### (e.g. Firefox, Thunderbird, Chromium)
### Mozilla uses cert8, Chromium and Chrome use cert9

###
### Requirement: apt install libnss3-tools
###

###
### CA file to install (CUSTOMIZE!)
###

certfile="rootCA.pem"
certname="My Root CA"

###
### For cert8 (legacy - DBM)
###

for certDB in $(find ~/ -name "cert8.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d dbm:${certdir}
done

###
### For cert9 (SQL)
###

for certDB in $(find ~/ -name "cert9.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d sql:${certdir}
done