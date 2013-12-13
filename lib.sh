EVENT_FILE="/var/log/gs/gs.log"

function createDir {
  mkdir $1
#  echo "создал директорию: $1"
  chmod 0700 $1
}

function createFile {
  touch $1
#  echo "создал файл: $1"
  chmod 0600 $1
}

function addLog {
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] $1" >> $EVENT_FILE 
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] $1" 
}

BACKTITLE="--backtitle Graphic_openSSL_framework"
CLEAR="--clear"
WIDGET="--and-widget"
OPTIONS="$BACKTITLE $CLEAR"

function ifCancel {
  if [ $? == 1 ]; then
    ./gs.sh
  fi
}

function getString {
  dialog --stdout $OPTIONS --inputbox "$1" 0 0 "$2"
  ifCancel
}

function showMsg {
  dialog --stdout $OPTIONS --title "$1" --msgbox "$2" 0 0
  ifCancel
}

function showYesNo {
  dialog --stdout $OPTIONS --title "$1"  --yesno "$2" 0 0
  ifCancel
}

function getNewCaName {
  while [ -d "/etc/ssl/$var" ]; do
    var=$(getString 'Input new CA name' 'ca-')
      if [ -d "/etc/ssl/$var" ]; then
        showMsg 'Error' "$var: This CA already exist, please input another name"
      fi
    done
  echo -n "$var"
}

function getNewFileName {
  var='ca'
    while [ -f "/etc/ssl/$1/certs/$var.crt" ]; do
      var=$(getString "Input $2" "$3")
      if [ -f "/etc/ssl/$1/certs/$var.crt" ]; then
        showMsg 'Error' "$var: This certificate already exist, please input another name"
      fi
    done
  echo -n "$var"
}

function getFileName {
  list=`ls "$1" | grep "$2"`
  options=`
  for var in $list; do
    echo "$var" "$2"
  done`
  fileName=$(dialog --stdout $OPTIONS --menu "$3" 0 0 0  ${options[@]})
  ifCancel
  echo -n $fileName
}

function getOrgName {
  list=`$1`
  options=`
  for var in $list; do
    echo $var
  done`
  orgName=$(dialog --stdout $OPTIONS --menu "Choise organization" 0 0 0  ${options[@]})
  ifCancel
  echo -n $orgName
}

function checkCaFile {
  if [ ! -d "/etc/ssl/$1" ]; then
    addLog "not exist CA [$1]"
    continue
    return 1
  elif [ -f "/etc/ssl/$1/certs/$2.crt" ]; then
    addLog "already exist files [$2] in CA [$1]"
    continue
    return 1
  fi
}

function createCaFs {
  createDir "$1"
  createDir "$1/certs"
  createDir "$1/private"
  createDir "$1/crl"
  createDir "$1/requests"
  createDir "$1/newcerts"
  createDir "$1/db"
  createFile "$1/db/index.txt"
  createFile "$1/db/serial"
  createFile "$1/crl/crlnumber"
  echo '01' > "$1/db/serial"
  echo '01' > "$1/crl/crlnumber"
}

function show {
  ext=`echo $1 | grep -oe '[a-z]\{3\}$'`
  case "$ext" in
    csr ) openssl req -noout -text -in "$1" | less ;;
    key ) openssl rsa -noout -text -in "$1" | less ;;
    crt ) openssl x509 -noout -text -in "$1" | less ;;
  esac
  return 0
}

#====================

function createCa {
  caName=$(getNewCaName)
  commonName=$(getString 'Input Commom Name')
  orgName=$(getString 'Input Organization Name')
  if [ $caName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  CA=1  
  EXT='v3_ca'
  return 0
}

function createInterCa {
  caName=$(getFileName "/etc/ssl" "ca" "Choise root CA")
  newCaName=$(getNewCaName)
  commonName=$(getNewFileName "$caName" 'Commom Name')
  orgName=$(getString 'Input Organization Name')
  if [ $caName ] && [ $newCaName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  KEY_REQ=1
  CRT=1
  INT_CA=1
  REQ_EXT='v3_ca_req'
  EXT='v3_ca'
  return 0
}

function createKeyCrt {
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  commonName=$(getNewFileName "$caName" 'Common Name')
  orgName=$(getString 'Input Organization Name')
  if [ $caName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  KEY_REQ=1
  CRT=1
  REQ_EXT='v3_req'
  EXT='v3_req'
  return 0
}

function createVpnServerCrt {
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  commonName=$(getNewFileName "$caName" 'Common Name')
  orgName=$(getString 'Input Organization Name')
  if [ $caName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  KEY_REQ=1
  CRT=1
  EXT="ssl_srv"
  REQ_EXT="v3_req"
  return 0
}

function createHttpsServerCrt {
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  commonName=$(getNewFileName "$caName" 'Common Name')
  orgName=$(getString 'Input Organization Name')
  if [ $caName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  KEY_REQ=1
  CRT=1
  EXT="https_srv"
  REQ_EXT="v3_req"
  return 0
}

function createSquidHttpsCrt {
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  commonName=$(getNewFileName "$caName" 'Common Name')
  orgName=$(getString 'Input Organization Name')
  if [ $caName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  KEY_REQ=1
  CRT=1
  EXT="https_squid"
  REQ_EXT="v3_req"
  return 0
}

function createRdpServerCrt {
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  commonName=$(getNewFileName "$caName" 'Common Name')
  orgName=$(getString 'Input Organization Name')
  if [ $caName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  KEY_REQ=1
  CRT=1
  EXT="ssl_rdp"
  REQ_EXT="v3_req"
  return 0
}

function createSensorCrt {
#  caName='ca-cmvpn'
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  orgName=$(getOrgName "cat lists/orgs.txt")
  sensorNomber=$(getString 'Input Sensor Nomber' '1')
  commonName=$(getNewFileName "$caName" "sensor name" "$orgName-sn0$sensorNomber")
  if [ $caName ] && [ $commonName ] && [ $orgName ]; then
    GEN=1
  fi
  KEY_REQ=1
  CRT=1
  EXT='v3_req'
  REQ_EXT="v3_req"
  return 0
}

function createCrtFromList {
  file="lists/$(getFileName "lists" "txt" "Выберите файл")"
  KEY_REQ=1
  CRT=1
  REQ_EXT='v3_req'
  EXT='v3_req'
  while read line; do
    generator $line
  done < $file
  return 0
}

function viewCa {
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  dirName=$(getFileName "/etc/ssl/$caName" "^certs\|private\|requests" "Choise dir")
  fileName=$(getFileName "/etc/ssl/$caName/$dirName" "key$\|crt$\|csr$" "Choise file for view")
  show "/etc/ssl/$caName/$dirName/$fileName"
  return 0
}

function revokeCrt {
  GEN=1
  REV=1
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  commonName=$(getFileName "/etc/ssl/$caName/certs" "crt" "Choise certificate for revoke")
  commonName=$(echo -n $commonName | sed 's/.crt$//')
  return 0
}

function createCrlList() {
  GEN=1
  CRL=1
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA")
  return 0
}

function deleteCa {
  caName=$(getFileName "/etc/ssl" "ca" "Choise CA for remove")
  yesNo=$(showYesNo "Delete?" "Do you want to delete CA $caName?")
  case $? in
    0) rm -r ../$caName ;
       showMsg 'Done' "$caName: not exist";
       addLog "deleted CA [$caName]"
       return 0 ;;
    1) return 0 ;;
  esac
}
