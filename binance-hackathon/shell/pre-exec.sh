#!/usr/bin/env bash
PRE_VERSION=0.1.1
PRE_UPDATE=2019-1-11
PRE_AUTHOR="Cloudgen Wong"
PRE_NAME=pre-exec.sh

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

function init_exe {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_33FE4=$APP_ID
    APP_ID="$APP_ID->"PRE
  else
    APP_ID=PRE
  fi
  PRE_SCRIPT=$($READLINK -f "$0")
  PRE_SCRIPTPATH=$(dirname "$PRE_SCRIPT")
  PRE_PROJECT_PATH=$(echo $PRE_SCRIPTPATH | $SED -e "s/\/shell//g" )
  PRE_PROJECT_NAME=$(cat $PRE_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PRE_PROJECT_VERSION=$(cat $PRE_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PRE_PROJECT_UPDATE=$(cat $PRE_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PRE_PARENT_PATH=$(echo $PRE_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $PRE_PROJECT_PATH/shell/hello.sh "$PRE_VERSION" "$PRE_UPDATE" "$PRE_AUTHOR" "$APP_ID" "$PRE_NAME"
  GIT_GROUP_NAME=$(cat $GIT_PROJECT_PATH/package.json |grep \"git-group-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GIT_SERVER_NAME=$(cat $GIT_PROJECT_PATH/package.json |grep \"git-server-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")

  printf "${LIGHT_GRAY}$APP_ID:]${NC} Current Folder: $PRE_PROJECT_PATH [${GREEN}FOUND${NC}]\n"
  if [ -f $PRE_PROJECT_PATH/.env ]; then
    printf "${LIGHT_GRAY}$APP_ID:]${NC} .env in current folder [${GREEN}FOUND${NC}]\n"
    export ENV_PATH=$PRE_PROJECT_PATH/.env
  else
    if [ -f $PRE_PROJECT_PATH/main/.env ]; then
      printf "${LIGHT_GRAY}$APP_ID:]${NC} .env in 'main' [${GREEN}FOUND${NC}]\n"
      export ENV_PATH=$PRE_PROJECT_PATH/main/.env
    fi
  fi
}

function end_exe {
  $PRE_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_33FE4 ]; then
    APP_ID=$OLD_APP_ID_33FE4
  fi
}

# start with main code
init_env
init_exe

source $PRE_PROJECT_PATH/shell/envCheck.sh $ENV_PATH
if [ ! -z "$ENV_PASS" ]; then
  source $PRE_PROJECT_PATH/shell/gitCheck.sh "$GIT_SERVER_NAME" lib open-api
  source $PRE_PROJECT_PATH/shell/dependency.sh $PRE_PARENT_PATH $PRE_PROJECT_PATH $PRE_PROJECT_NAME

  if [ "$PRE_PROJECT_NAME" != "Main" ]; then
    source $PRE_PROJECT_PATH/shell/install2main.sh $PRE_PARENT_PATH $PRE_PROJECT_PATH $PRE_PROJECT_NAME
  fi
  source $PRE_PROJECT_PATH/shell/npm-install.sh
else
  printf "${BROWN}$APP_ID:>${NC} Project execution [${RED}FAILED${NC}]\n"
fi
$PRE_PROJECT_PATH/shell/bye.sh $APP_ID
if [ ! -z $OLD_APP_ID_33FE4 ]; then
  APP_ID=$OLD_APP_ID_33FE4
fi
