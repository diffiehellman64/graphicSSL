#!/bin/bash
. lib.sh

function generator(){
  . ./settings.sh  "$1" "$2" "$3"
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
  [ $CRL ] && CRL_FILE="$CRL_DIR/`date +'%y%m%d-%H%M'`.crl" && \
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
    4 'Create a certificate for server' \
    5 'Create certificates for sensor' \
    6 'Create certificates from list' \
    7 'View CA' \
    8 'Revoke certificate' \
    9 'Create a list of revoked certificates' \
    10 'Delete CA' )
  case $action in
    1) createCa ;;
    2) createInterCa ;;
    3) createKeyCrt ;;
    4) createServerCrt ;;
    5) createSensorCrt ;;
    6) createCrtFromList ;;
    7) viewCa ;;
    8) revokeCrt ;;
    9) createCrlList ;;
   10) deleteCa ;;
  esac
  [ $GEN ] && generator "$caName" "$commonName" "$orgName"
}
mainMenu
#if [ $? == 0 ]; then
#  mainMenu
#fi
