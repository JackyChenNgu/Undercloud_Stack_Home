#!/bin/bash

set -eux

### --start_docs
## Generating the overcloud SSL Certificates
## =========================================

## * Generate a private key
## ::

openssl genrsa 2048 > /home/stack/overcloud-ca-privkey.pem 2> /dev/null

## * Generate a self-signed CA certificate
## ::

openssl req -new -x509 -key /home/stack/overcloud-ca-privkey.pem \
    -out /home/stack/overcloud-cacert.pem -days 365 \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=OOOQ/CN=overcloud"

## * Add the self-signed CA certificate to the undercloud's trusted certificate
##   store.
## ::

sudo cp /home/stack/overcloud-cacert.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract

## * Generate the leaf certificate request and key that will be used for the
##   public VIP
## ::


openssl req -newkey rsa:2048 -days 365 \
    -nodes -keyout /home/stack/server-key.pem \
    -out /home/stack/server-req.pem \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=OOOQ/CN=10.0.0.5" \
    -reqexts subjectAltName \
    -config <(printf "[subjectAltName]\nsubjectAltName=IP:10.0.0.5\n[req]req_extensions = v3_req\ndistinguished_name=req_distinguished_name\n[req_distinguished_name]")

## * Process the server RSA key
## ::

openssl rsa -in /home/stack/server-key.pem \
    -out /home/stack/server-key.pem

## * Sign the leaf certificate with the CA certificate and generate
##   the certificate
## ::

openssl x509 -req -in /home/stack/server-req.pem -days 365 \
    -CA /home/stack/overcloud-cacert.pem \
    -CAkey /home/stack/overcloud-ca-privkey.pem \
    -set_serial 01 -out /home/stack/server-cert.pem \
    -extensions subjectAltName \
    -extfile <(printf "[subjectAltName]\nsubjectAltName=IP:10.0.0.5\n[req]req_extensions = v3_req\ndistinguished_name=req_distinguished_name\n[req_distinguished_name]")

## --stop_docs
