#!/usr/bin/env bash
NRT_VERSION=0.1.2
NRT_UPDATE=2018-12-28
NRT_AUTHOR="Cloudgen Wong"
NRT_NAME=npm-remove-test.sh

function init_env {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  LIGHT_GRAY='\033[0;37m'
  DARK_GRAY='\033[0;35m'
  PURPLE='\033[0;30m'
  BROWN='\033[0;33m'
  NC='\033[0m' # No Color
  if [[ `uname` == 'Darwin' ]]; then
    READLINK=$( which greadlink )
    if [ -z "$READLINK" ]; then
      printf "${BROWN}$APP_ID:>${NC} GNU utils for Mac [${RED}REQUIRED${NC}]\n"
      printf "${BROWN}$APP_ID:]${NC} You may use homebrew to install them: brew install coreutils gnu-readlink\n"
      exit 1
    fi
    SED=$( which gsed )
    if [ -z "$SED" ]; then
      printf "${BROWN}$APP_ID:>${NC} GNU utils for Mac [${RED}REQUIRED${NC}]\n"
      printf "${BROWN}$APP_ID:]${NC} You may use homebrew to install them: brew install coreutils gnu-sed\n"
      exit 1
    else
      IS_DARWIN=1
    fi
  else
    READLINK=$(which readlink)
    SED=$(which sed)
    IS_DARWIN=0
  fi
  NODE=$(which node)
  NPM=$(which npm)
}

function init_nrt {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_H227C=$APP_ID
    APP_ID="$APP_ID->"NRT
  else
    APP_ID=NRT
  fi
  NRT_SCRIPT=$($READLINK -f "$0")
  NRT_SCRIPTPATH=$(dirname "$NRT_SCRIPT")
  NRT_PROJECT_PATH=$(echo $NRT_SCRIPTPATH | $SED -e "s/\/shell//g" )
  NRT_PROJECT_NAME=$(cat $NRT_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  NRT_PROJECT_VERSION=$(cat $NRT_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  NRT_PROJECT_UPDATE=$(cat $NRT_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  NRT_PARENT_PATH=$(echo $NRT_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $NRT_PROJECT_PATH/shell/hello.sh "$NRT_VERSION" "$NRT_UPDATE" "$NRT_AUTHOR" "$APP_ID" "$NRT_NAME"

  if [ -f $NRT_PROJECT_PATH/meta/npm-test-folder-list.txt ]; then
    TEST_FOLDER_LIST=$(cat $NRT_PROJECT_PATH/meta/npm-test-folder-list.txt)
    TEST_FOLDER_LIST_NOT_FOUND=0
  else
    TEST_FOLDER_LIST_NOT_FOUND=1
  fi
  printf "${LIGHT_GRAY}$APP_ID:]${NC} Current plugin name: $NRT_PROJECT_NAME version $NRT_PROJECT_VERSION ($NRT_PROJECT_UPDATE) [${GREEN}OK${NC}]\n"
}

function end_nrt {
  $NRT_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_H227C ]; then
    APP_ID=$OLD_APP_ID_H227C
  fi
}

# start with main code
init_env
init_nrt
if [ "$TEST_FOLDER_LIST_NOT_FOUND" != "1" ]; then
  for FOLDER in $TEST_FOLDER_LIST
  do
    if [ ! -z "main/$FOLDER" ]; then
      if [ -x main/$FOLDER ]; then
        rm -rf "main/$FOLDER"
        printf "${LIGHT_GRAY}$APP_ID:]${NC} main/$FOLDER [${GREEN}REMOVED${NC}]\n"
      fi
    fi
  done
else
  printf "${BROWN}$APP_ID:>${NC} project-list.txt [${RED}NOT FOUND]${NC}]\n"
fi
end_nrt
