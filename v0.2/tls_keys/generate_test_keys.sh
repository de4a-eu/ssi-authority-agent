#!/bin/sh
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e
#openssl rand -writerand ~/.rnd
openssl rand -out ~/.rnd 1024
mkdir -p keys/tls
echo "Generating Aries-Framework-Go Test PKI"

tmp=$(mktemp)
echo "subjectKeyIdentifier=hash
authorityKeyIdentifier = keyid,issuer
extendedKeyUsage = serverAuth
keyUsage = Digital Signature, Key Encipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = 192.168.1.47
DNS.3 = government.agent.de4a.eu
DNS.4 = citizen.agent.de4a.eu" >> "$tmp"

#create CA
echo "Creating CA"
openssl ecparam -name prime256v1 -genkey -noout -out keys/tls/ec-cakey.pem
openssl req -new -x509 -key keys/tls/ec-cakey.pem -subj "/C=CA/ST=ON/O=Example Internet CA Inc.:CA Sec/OU=CA Sec" -out keys/tls/ec-cacert.pem
echo "CA created"
echo "Creating Credentials"
#create TLS creds
openssl ecparam -name prime256v1 -genkey -noout -out keys/tls/ec-key.pem
openssl req -new -key keys/tls/ec-key.pem -subj "/C=CA/ST=ON/O=Example Inc.:Aries-Framework-Go/OU=Aries-Framework-Go/CN=*.de4a.eu" -out keys/tls/ec-key.csr
openssl x509 -req -in keys/tls/ec-key.csr -CA keys/tls/ec-cacert.pem -CAkey keys/tls/ec-cakey.pem -CAcreateserial -extfile "$tmp" -out keys/tls/ec-pubCert.pem -days 365
echo "Credentials created"

echo "done generating Aries-Framework-Go PKI"
