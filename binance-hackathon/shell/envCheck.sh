#!/usr/bin/env bash
ENV_VERSION=0.1.9
ENV_UPDATE=2018-1-9
ENV_AUTHOR="Vivian Kwan"
ENV_NAME=envCheck.sh

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

function init {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_4Y168=$APP_ID
    APP_ID="$APP_ID->"CHK
  else
    APP_ID=CHK
  fi
  ENV_SCRIPT=$($READLINK -f "$0")
  ENV_SCRIPTPATH=$(dirname "$ENV_SCRIPT")
  ENV_PROJECT_PATH=$(echo $ENV_SCRIPTPATH | $SED -e "s/\/shell//g" )
  ENV_PROJECT_NAME=$(cat $ENV_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  ENV_PROJECT_VERSION=$(cat $ENV_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  ENV_PROJECT_UPDATE=$(cat $ENV_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  ENV_PARENT_PATH=$(echo $ENV_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $ENV_PROJECT_PATH/shell/hello.sh "$ENV_VERSION" "$ENV_UPDATE" "$ENV_AUTHOR" "$APP_ID" "$ENV_NAME"
}

function end {
  $ENV_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_4Y168 ]; then
    APP_ID=$OLD_APP_ID_4Y168
  fi
}

function envCheck {
  if [ ! -z $1 ]; then
    ENV_PATH=$1
    PARAM_LIST=$(cat $ENV_PROJECT_PATH/meta/env-param-list.txt)
    for ENV_PARAM in $PARAM_LIST
    do
      checkString "$ENV_PATH" "$ENV_PARAM"
    done
  else
    ENV_PASS=""
    printf "${BROWN}$APP_ID:>${NC} envCheck parameters '$ENV_NAME' [${RED}MISSING${NC}]\n"
  fi
}

function checkString {
  local ENV_PATH=$1
  local ENV_NAME=$2
  local ENV_STRING=$(cat $ENV_PATH|grep "$ENV_NAME"\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")

  if [ ! -z "$ENV_STRING" -a "$ENV_STRING" != "" ]; then
    printf "${LIGHT_BLUE}$APP_ID:]${NC} envCheck '$ENV_NAME' [${GREEN}FOUND${NC}]\n"
  else
    ENV_PASS=""
    printf "${BROWN}$APP_ID:>${NC} envCheck '$ENV_NAME' [${RED}NOT FOUND${NC}]\n"
  fi
}

init_env
init
ENV_PASS=1
# start with main code
if [ ! -z $1 ]; then
  ENV_PROJECT_ENV=$1
else
  ENV_PROJECT_ENV=$ENV_PROJECT_PATH/.env
fi

if [ -f $ENV_PROJECT_ENV ]; then
  envCheck "$ENV_PROJECT_ENV"
  end
else
  ENV_PASS=""
  printf "${BROWN}$APP_ID:>${NC} file '$ENV_PROJECT_ENV' [${RED}NOT FOUND${NC}]\n"
fi
