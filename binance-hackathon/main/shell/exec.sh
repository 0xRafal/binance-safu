#!/usr/bin/env bash
EXE_VERSION=0.1.25
EXE_UPDATE=2019-1-7
EXE_AUTHOR="Cloudgen Wong"
EXE_NAME=exec.sh

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
    OLD_APP_ID_35D16=$APP_ID
    APP_ID="$APP_ID->"EXE
  else
    APP_ID=EXE
  fi
  EXE_SCRIPT=$($READLINK -f "$0")
  EXE_SCRIPTPATH=$(dirname "$EXE_SCRIPT")
  EXE_PROJECT_PATH=$(echo $EXE_SCRIPTPATH | $SED -e "s/\/shell//g" )
  EXE_PROJECT_NAME=$(cat $EXE_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  EXE_PROJECT_VERSION=$(cat $EXE_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  EXE_PROJECT_UPDATE=$(cat $EXE_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  EXE_PARENT_PATH=$(echo $EXE_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $EXE_PROJECT_PATH/shell/hello.sh "$EXE_VERSION" "$EXE_UPDATE" "$EXE_AUTHOR" "$APP_ID" "$EXE_NAME"
  printf "${LIGHT_GRAY}$APP_ID:]${NC} Current Folder: $EXE_PROJECT_PATH [${GREEN}FOUND${NC}]\n"
  if [ -f $EXE_PROJECT_PATH/.env ]; then
    printf "${LIGHT_GRAY}$APP_ID:]${NC} .env in current folder [${GREEN}FOUND${NC}]\n"
    export ENV_PATH=$EXE_PROJECT_PATH/.env
  else
    if [ -f $EXE_PROJECT_PATH/main/.env ]; then
      printf "${LIGHT_GRAY}$APP_ID:]${NC} .env in 'main' [${GREEN}FOUND${NC}]\n"
      export ENV_PATH=$EXE_PROJECT_PATH/main/.env
    fi
  fi
}

function end_exe {
  $EXE_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_35D16 ]; then
    APP_ID=$OLD_APP_ID_35D16
  fi
}

# start with main code
init_env
init_exe

source $EXE_PROJECT_PATH/shell/envCheck.sh $ENV_PATH
if [ ! -z "$ENV_PASS" ]; then
  source $EXE_PROJECT_PATH/shell/gitCheck.sh
  source $EXE_PROJECT_PATH/shell/dependency.sh $EXE_PARENT_PATH $EXE_PROJECT_PATH $EXE_PROJECT_NAME

  if [ "$EXE_PROJECT_NAME" != "Main" ]; then
    source $EXE_PROJECT_PATH/shell/install2main.sh $EXE_PARENT_PATH $EXE_PROJECT_PATH $EXE_PROJECT_NAME
  fi
  source $EXE_PROJECT_PATH/shell/npm-install.sh
  if [ -z $1 ]; then
    if [ "$EXE_PROJECT_NAME" == "Main" ]; then
      cd $EXE_PROJECT_PATH && $NODE $EXE_PROJECT_PATH/main.js
    else
      cd $EXE_PROJECT_PATH && $NODE $EXE_PROJECT_PATH/plugin.js
      MAIN_PATH=$EXE_PARENT_PATH/main
      MAIN_PACKAGE_PATH=$MAIN_PATH/node_modules
      if [ ! -z $MAIN_PACKAGE_PATH ]; then
        if [ -x $MAIN_PACKAGE_PATH ]; then
          source $EXE_PROJECT_PATH/shell/clean.sh
        fi
      fi
    fi
  else
    cd $EXE_PROJECT_PATH && $NODE $EXE_PROJECT_PATH/$1
  fi
else
  printf "${BROWN}$APP_ID:>${NC} Project execution [${RED}FAILED${NC}]\n"
fi
$EXE_PROJECT_PATH/shell/bye.sh $APP_ID
if [ ! -z $OLD_APP_ID_35D16 ]; then
  APP_ID=$OLD_APP_ID_35D16
fi
