#!/usr/bin/env bash
VER_VERSION=0.1.9
VER_UPDATE=2018-1-7
VER_AUTHOR="Cloudgen Wong"
VER_NAME=new-version.sh

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

function init_ver {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_Y3G38=$APP_ID
    APP_ID="$APP_ID->"VER
  else
    APP_ID=VER
  fi
  VER_SCRIPT=$($READLINK -f "$0")
  VER_SCRIPTPATH=$(dirname "$VER_SCRIPT")
  VER_PROJECT_PATH=$(echo $VER_SCRIPTPATH | $SED -e "s/\/shell//g" )
  VER_PROJECT_NAME=$(cat $VER_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  VER_PROJECT_VERSION=$(cat $VER_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  VER_PROJECT_UPDATE=$(cat $VER_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  VER_PARENT_PATH=$(echo $VER_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $VER_PROJECT_PATH/shell/hello.sh "$VER_VERSION" "$VER_UPDATE" "$VER_AUTHOR" "$APP_ID" "$VER_NAME"
}

function end_ver {
  $VER_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_Y3G38 ]; then
    APP_ID=$OLD_APP_ID_Y3G38
  fi
}

function get_next_subversion {
  if [ ! -z $1 ]; then
    PROJECT_VERSION=$1
    IS_DARWIN=$2
    VERBOSE=$3
    PROJECT_MAJOR=$(echo $PROJECT_VERSION| $SED -r "s/\.[^\.]+$//")
    PROJECT_MINOR=$(echo $PROJECT_VERSION| $SED -r "s/^.+\.//")
    NEW_PROJECT_MINOR=$(( $PROJECT_MINOR + 1 ))
    export NEW_PROJECT_VERSION="$PROJECT_MAJOR.$NEW_PROJECT_MINOR"

    if [ ! -z "$VERBOSE" ]; then
      printf "${BROWN}$APP_ID:]${NC} New version: $NEW_PROJECT_VERSION"
    fi
  else
    printf "${BROWN}$APP_ID:>${NC} get_next_subversion parameter [${RED}REQUIRED${NC}]\n"
  fi
}

# start with main code
if [ ! -z $1 ] ; then
  init_env
  init_ver
  PROJECT_VERSION=$1
  VERBOSE=$2
  get_next_subversion "$PROJECT_VERSION" "$IS_DARWIN" "$VERBOSE"
  end_ver
else
  printf "${BROWN}$APP_ID:>${NC}  new-version.sh parameter [${RED}MISSING${NC}]\n"
fi
