#!/bin/bash
. lib.sh
#openssl pkcs12 -export -in rdp-srv.crt -inkey ../private/rdp-srv.key -certfile ca.crt -name "Cert for Ivan" -out cert.p12

function generator(){
export ROOT="/etc/ssl/$1"
export CERTS_DIR="$ROOT/certs"
export PRIVATE_DIR="$ROOT/private"
export NEWCERTS_DIR="$ROOT/newcerts"
export CRL_DIR="$ROOT/crl"
export REQUESTS_DIR="$ROOT/requests"
export DB_DIR="$ROOT/db"
export INDEX_FILE="$DB_DIR/index.txt"
export SERIAL_FILE="$DB_DIR/serial"
export CRLNUM_FILE="$CRL_DIR/crlnumber"
CONFIG="`pwd`/openssl.cnf"
BATCH='-batch'
export KEY_C="RU"
export KEY_P="Komi Republic"
export KEY_L="Syktyvkar"
export KEY_O="$3"
export KEY_OU=""
export KEY_CN="$2"
export KEY_E="diffiehellman@mail.ru"
KEY_FILE="$PRIVATE_DIR/$KEY_CN.key"
REQ_FILE="$REQUESTS_DIR/$KEY_CN.req"
CRT_FILE="$CERTS_DIR/$KEY_CN.crt"
EVENT_FILE="/var/log/gs/gs.log"
#export BITS="4096"
export BITS="2048"
export DAYS="3650"
export ENC_KEY="no"

  [ $CA ] && createCaFs "/etc/ssl/$1" && \
             openssl req "$BATCH" -config "$CONFIG" -new -x509 -extensions $EXT -keyout "$PRIVATE_DIR/ca.key" -out "$CERTS_DIR/ca.crt" && \
             chmod 400 "$PRIVATE_DIR/ca.key" && \
             chmod 444 "$CERTS_DIR/ca.crt" && \
             addLog "created new CA [$1]"
  [ $KEY_REQ ] && checkCaFile "$1" "$2" && \
                  openssl req "$BATCH" -config "$CONFIG" -new -keyout "$KEY_FILE" -out "$REQ_FILE" -reqexts "$REQ_EXT" && \
                  chmod 400 "$KEY_FILE" && \
                  chmod 444 "$REQ_FILE" && \
                  addLog "created key [$KEY_FILE] and request [$REQ_FILE]"
  [ $CRT ] && openssl ca  "$BATCH" -config "$CONFIG" -out "$CRT_FILE" -in "$REQ_FILE" -extensions "$EXT" && \
              chmod 444 "$CRT_FILE" && \
              addLog "signed request [$REQ_FILE] into certificate [$CRT_FILE]"
  [ $INT_CA ] && createCaFs "/etc/ssl/$newCaName" && \
                 cp "$KEY_FILE" "/etc/ssl/$newCaName/private/ca.key" && \
                 cp "$CRT_FILE" "/etc/ssl/$newCaName/certs/ca.crt" && \
                 addLog "created intermediate CA [$newCaName] on the certificate [$CRT_FILE]"
  [ $REV ] && openssl ca -revoke "$CRT_FILE" -config "$CONFIG" && \
              addLog "revoked certificate [$CRT_FILE]"
  [ $CRL ] && CRL_FILE="$CRL_DIR/$1.crl" && \
              openssl ca -gencrl -out "$CRL_FILE" -config "$CONFIG" && \
              chmod 444 "$CRL_FILE" && \
              addLog "created revoked certificates list [$CRL_FILE]"
  return 0
}

function mainMenu(){
  action=$(dialog --stdout --backtitle "Graphic openSSL framework" --menu "Choise action" 0 0 0  \
    1 'Create a root CA' \
    2 'Create intermediate CA' \
    3 'Create certificate' \
    4 'Create a certificate for VPN server' \
    5 'Create a certificate for HTTPS server' \
    6 'Create a certificate for RDP server' \
    7 'Create certificates for sensor' \
    8 'Create certificates from list' \
    9 'View CA' \
    10 'Revoke certificate' \
    11 'Create a list of revoked certificates' \
    12 'Delete CA' )
  case $action in
    1) createCa ;;
    2) createInterCa ;;
    3) createKeyCrt ;;
    4) createVpnServerCrt ;;
    5) createHttpsServerCrt ;;
    6) createRdpServerCrt ;;
    7) createSensorCrt ;;
    8) createCrtFromList ;;
    9) viewCa ;;
   10) revokeCrt ;;
   11) createCrlList ;;
   12) deleteCa ;;
  esac
  [ $GEN ] && generator "$caName" "$commonName" "$orgName"
}
mainMenu
