#!/usr/bin/env bash
ABT_VERSION=0.1.14
ABT_UPDATE=2018-1-9
ABT_AUTHOR="Cloudgen Wong"
ABT_NAME=about.sh

function init_env {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  LIGHT_GRAY='\033[0;37m'
  LIGHT_BLUE='\033[0;34m'
  LIGHT_GREEN='\033[0;32m'
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

function init_abt {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_24C3G=$APP_ID
    APP_ID="$APP_ID->"ABT
  else
    APP_ID=ABT
  fi
  ABT_SCRIPT=$($READLINK -f "$0")
  ABT_SCRIPTPATH=$(dirname "$ABT_SCRIPT")
  ABT_PROJECT_PATH=$(echo $ABT_SCRIPTPATH | $SED -e "s/\/shell//g" )
  ABT_PROJECT_NAME=$(cat $ABT_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  ABT_PROJECT_VERSION=$(cat $ABT_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  ABT_PROJECT_UPDATE=$(cat $ABT_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  ABT_PARENT_PATH=$(echo $ABT_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $ABT_PROJECT_PATH/shell/hello.sh "$ABT_VERSION" "$ABT_UPDATE" "$ABT_AUTHOR" "$APP_ID" "$ABT_NAME"

  if [ -f $ABT_PROJECT_PATH/meta/project-list.txt ]; then
    PROJECT_LIST=$(cat $ABT_PROJECT_PATH/meta/project-list.txt)
    PROJECT_LIST_NOT_FOUND=0
  else
    PROJECT_LIST_NOT_FOUND=1
  fi
  printf "${LIGHT_BLUE}$APP_ID:]${NC} Current plugin name: $ABT_PROJECT_NAME version $ABT_PROJECT_VERSION ($ABT_PROJECT_UPDATE) [${GREEN}OK${NC}]\n"
}

function end_abt {
  $ABT_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_24C3G ]; then
    APP_ID=$OLD_APP_ID_24C3G
  fi
}

# start with main code
init_env
init_abt
end_abt
