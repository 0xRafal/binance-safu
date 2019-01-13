#!/usr/bin/env bash
NPM_VERSION=0.1.7
NPM_UPDATE=2018-12-28
NPM_AUTHOR="Cloudgen Wong"
NPM_NAME=npm-install.sh

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

function init_npm {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_34DFD=$APP_ID
    APP_ID="$APP_ID->"NPM
  else
    APP_ID=NPM
  fi
  NPM_SCRIPT=$($READLINK -f "$0")
  NPM_SCRIPTPATH=$(dirname "$NPM_SCRIPT")
  NPM_PROJECT_PATH=$(echo $NPM_SCRIPTPATH | $SED -e "s/\/shell//g" )
  NPM_PROJECT_NAME=$(cat $NPM_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  NPM_PROJECT_VERSION=$(cat $NPM_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  NPM_PROJECT_UPDATE=$(cat $NPM_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  NPM_PARENT_PATH=$(echo $NPM_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $NPM_PROJECT_PATH/shell/hello.sh "$NPM_VERSION" "$NPM_UPDATE" "$NPM_AUTHOR" "$APP_ID" "$NPM_NAME"
  printf "${LIGHT_BLUE}$APP_ID:]${NC} Current plugin name: $NPM_PROJECT_NAME version $NPM_PROJECT_VERSION ($NPM_PROJECT_UPDATE) [${GREEN}FOUND${NC}]\n"
}

function end_npm {
  $NPM_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_34DFD ]; then
    APP_ID=$OLD_APP_ID_34DFD
  fi
}

# start with main code
init_env
init_npm
if [ ! -z "$NPM_PROJECT_PATH" ]; then
  if [ -x $NPM_PROJECT_PATH ]; then
    NPM_MAIN_PATH=$NPM_PARENT_PATH/main
    if [ ! -z "$NPM_MAIN_PATH" ]; then
      if [ -x $NPM_MAIN_PATH ]; then
        cp -r $NPM_MAIN_PATH/node_modules $NPM_PROJECT_PATH
        rm -rf $NPM_PROJECT_PATH/node_modules/.bin
      else
        printf "${LIGHT_GREEN}$APP_ID:)${NC} Main path [${BROWN}NOT FOUND${NC}]\n"
      fi
    fi
    cd $NPM_PROJECT_PATH && $NPM install
    printf "${LIGHT_BLUE}$APP_ID:]${NC} npm install [${GREEN}DONE${NC}]\n"
  else
    printf "${BROWN}$APP_ID:>${NC} Project Path [${RED}NOT FOUND${NC}]\n"
  fi
else
  printf "${BROWN}$APP_ID:>${NC} Project Path [${RED}EMPTY${NC}]\n"
fi
end_npm
