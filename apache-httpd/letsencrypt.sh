#!/bin/bash

# Fixed Path for SSL  
keyDIR=/opt/apache/conf/ssl/letsencrypt
codeDIR=/opt/APPS/snf-tom0/webapps
acmeURL="https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py"

# Creating directory Account Key 
mkdir -p $keyDIR
openssl genrsa 4096 > $keyDIR/account.key
# Print Public Key
#openssl rsa -in $keyDIR/account.key -pubout

# Creating Domain Key and CSR
openssl genrsa 4096 > $keyDIR/domain.key
# For Single Domain Only
#openssl req -new -sha256 \
#	-key 	$keyDIR/domain.key \
#	-subj 	"/CN=snfportal.in" > $keyDIR/domain.csr 
# For multiple domains (for both my.com & www.my.com)
openssl req -new -sha256 \
	-key 	$keyDIR/domain.key \
	-subj 	"/" -reqexts SAN -config <(
		cat /etc/pki/tls/openssl.cnf <(
			printf "[SAN]\nsubjectAltName=\
			DNS:fssai.tk,\
			DNS:*.fssai.tk"
		)
	) > $keyDIR/domain.csr

#

# Hosting challenge Files
mkdir -p $codeDIR/.well-known/acme-challenge	
echo "TEST" > $codeDIR/.well-known/acme-challenge/test.txt

# Get a signed certificate!
cd $keyDIR; wget $acmeURL

python $keyDIR/acme_tiny.py \
	--account-key $keyDIR/account.key \
	--csr $keyDIR/domain.csr \
	--acme-dir $codeDIR/.well-known/acme-challenge \
	> $keyDIR/domain.pem

# Creating a Renewal Script
cat <<EOF > $keyDIR/renew_cert.sh
#!/usr/bin/sh
python $keyDIR/acme_tiny.py \\
	--account-key $keyDIR/account.key \\
	--csr $keyDIR/domain.csr \\
	--acme-dir $codeDIR/.well-known/acme-challenge \\
	> $keyDIR/domain.pem || exit
systemctl reload apache
EOF

chmod +x $keyDIR/renew_cert.sh

# Adding Renewal Script to Cron
(crontab -l 2>/dev/null; 
echo "0 0 1 * * $keyDIR/renew_cert.sh \
>> $keyDIR/acme_tiny.log") | crontab -