#!/usr/bin/env bash

#
# gitCheck.sh [git-server] [project-name] [group-name]
#
# Example: shell/gitCheck.sh gitlab.hex authorization open-api
#   i.e. git clone git@gitlab.hex:open-api/authorization.git
#
# Example: shell/gitCheck.sh gitlab.hex bitcoin
#   i.e. git clone git@gitlab.hex:open-api/bitcoin.git
#
# Example: shell/gitCheck.sh gitlab.hex
#   i.e. git clone git@gitlab.hex:open-api/lib.git
#

GIT_VERSION=0.1.20
GIT_UPDATE=2018-1-9
GIT_AUTHOR="Cloudgen Wong"
GIT_NAME=gitCheck.sh
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

function init_git {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_24C3G=$APP_ID
    APP_ID="$APP_ID->"GIT
  else
    APP_ID=GIT
  fi
  GIT_SCRIPT=$($READLINK -f "$0")
  GIT_SCRIPTPATH=$(dirname "$GIT_SCRIPT")
  GIT_PROJECT_PATH=$(echo $GIT_SCRIPTPATH | $SED -e "s/\/shell//g" )
  GIT_PROJECT_NAME=$(cat $GIT_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GIT_PROJECT_VERSION=$(cat $GIT_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GIT_PROJECT_UPDATE=$(cat $GIT_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GIT_PARENT_PATH=$(echo $GIT_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  GIT_GROUP_NAME=$(cat $GIT_PROJECT_PATH/package.json |grep \"git-group-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GIT_SERVER_NAME=$(cat $GIT_PROJECT_PATH/package.json |grep \"git-server-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  $GIT_PROJECT_PATH/shell/hello.sh "$GIT_VERSION" "$GIT_UPDATE" "$GIT_AUTHOR" "$APP_ID" "$GIT_NAME"

}

function end_git {
  $GIT_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_24C3G ]; then
    APP_ID=$OLD_APP_ID_24C3G
  fi
}

function gitCheck {
  if [ ! -z $1 ] && [ ! -z $2 ]; then
    SERVER=$1
    REPOSITORY=$2
    GROUP=$3
    APP_ID=$4
    PROJECT_NAME=$5
    if ping -c1 $SERVER >/dev/null 2>&1
    then
      printf "${LIGHT_BLUE}$APP_ID:]${NC} $SERVER [${GREEN}FOUND${NC}]\n"
      printf "${LIGHT_BLUE}$APP_ID:]${NC} Trying to update repository of HexFramework.\n"
      if [ -x ./lib ]; then
        if [ "$PROJECT_NAME" != "BlankPlugin" ]; then
          printf "${LIGHT_BLUE}$APP_ID:]${NC} Old lib [${GREEN}FOUND${NC}]\n"
          rm -rf lib
        fi
      fi
      GIT_URL="git@$SERVER:$GROUP/$REPOSITORY.git"
      printf "${LIGHT_BLUE}$APP_ID:]${NC} Repository is at $GIT_URL [${GREEN}FOUND${NC}]\n"
      git clone $GIT_URL
    else
      printf "${LIGHT_GREEN}$APP_ID:)${NC} $SERVER [${BROWN}NOT FOUND${NC}]\n"
      printf "${LIGHT_GREEN}$APP_ID:)${NC} source code will not pull from server\n"
    fi
  else
    printf "${BROWN}$APP_ID:>${NC}gitCheck parameters '$ENV_NAME' [${RED}MISSING${NC}]\n"
  fi
}

# start with main code
init_env
init_git
if [ -z "$1" ]; then
  if [ -z "$GIT_SERVER_NAME" ]; then
    GIT_SERVER_NAME=gitlab.hex
  fi
else
  GIT_SERVER_NAME="$1"
fi
printf "${LIGHT_BLUE}$APP_ID:]${NC} Server-Name: $GIT_SERVER_NAME [${GREEN}FOUND${NC}]\n"

if [ -z "$3" ]; then
  if [ -z "$GIT_GROUP_NAME" ]; then
    GIT_GROUP_NAME="open-api"
  fi
else
  GIT_GROUP_NAME="$3"
fi
printf "${LIGHT_BLUE}$APP_ID:]${NC} Group-Name: $GIT_GROUP_NAME [${GREEN}FOUND${NC}]\n"

if [ -z "$2" ]; then
  if [ -z "$GIT_CHECKOUT_NAME" ]; then
    GIT_CHECKOUT_NAME="lib"
  fi
else
  GIT_CHECKOUT_NAME=$2
fi
printf "${LIGHT_BLUE}$APP_ID:]${NC} Checkout Name: $GIT_CHECKOUT_NAME [${GREEN}FOUND${NC}]\n"
gitCheck $GIT_SERVER_NAME $GIT_CHECKOUT_NAME $GIT_GROUP_NAME $APP_ID $GIT_PROJECT_NAME
end_git
