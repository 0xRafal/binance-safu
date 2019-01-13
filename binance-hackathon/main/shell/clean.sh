#!/usr/bin/env bash
CLN_VERSION=0.1.20
CLN_UPDATE=2018-1-7
CLN_AUTHOR="Cloudgen Wong"
CLN_NAME=clean.sh
CLN_ID=CLN

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

function init_cln {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_33C19=$APP_ID
    APP_ID="$APP_ID->"CLN
  else
    APP_ID=CLN
  fi
  CLN_SCRIPT=$($READLINK -f "$0")
  CLN_SCRIPTPATH=$(dirname "$CLN_SCRIPT")
  CLN_PROJECT_PATH=$(echo $CLN_SCRIPTPATH | $SED -e "s/\/shell//g" )
  CLN_PROJECT_NAME=$(cat $CLN_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  CLN_PROJECT_VERSION=$(cat $CLN_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  CLN_PROJECT_UPDATE=$(cat $CLN_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  CLN_PARENT_PATH=$(echo $CLN_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $CLN_PROJECT_PATH/shell/hello.sh "$CLN_VERSION" "$CLN_UPDATE" "$CLN_AUTHOR" "$APP_ID" "$CLN_NAME"
}

function end_cln {
  $CLN_PROJECT_PATH/shell/bye.sh "$APP_ID"
  if [ ! -z $OLD_APP_ID_33C19 ]; then
    APP_ID=$OLD_APP_ID_33C19
  fi
}


function remove_dependency {
  PROJECT_PATH=$1
  DEPENDENCY_NAME=$2
  APP_ID=$3
  REMOTE_PATH=$PROJECT_PATH/plugins/$DEPENDENCY_NAME
  if [ -x $REMOTE_PATH ]; then
    rm -rf $REMOTE_PATH
  else
    printf "${BROWN}$APP_ID:>${NC} Plugin '$REMOTE_PATH' [${RED}NOT FOUND${NC}]\n"
  fi
}

function dependency_removal_check {
  PARENT_PATH=$1
  PROJECT_PATH=$2
  PROJECT_NAME=$3
  APP_ID=$4
  PLUGIN_DEPENDENCIES=$(cat $PROJECT_PATH/package.json |grep \"plugin-dependencies\" |head -1|sed -r "s/\ *,\ */,/g" | $SED -r "s/.*:\ \"|\",//g")
  if [ ! -z $PLUGIN_DEPENDENCIES ]; then
    if [ "$PROJECT_NAME" == "Main" ]; then
      rm -rf ./plugins
      mkdir ./plugins
    else
      DEPENDENCY_NAMES=$(echo $PLUGIN_DEPENDENCIES|tr "," "\n")
      for DEPENDENCY_NAME in $DEPENDENCY_NAMES
      do
        REMOTE_PACKAGE_PATH=$PARENT_PATH/$DEPENDENCY_NAME/package.json
        if [ ! -z $REMOTE_PACKAGE_PATH ]; then
          if [ -f $REMOTE_PACKAGE_PATH ]; then
            REMOTE_PLUGIN_NAME=$(cat $REMOTE_PACKAGE_PATH |grep \"name\" |head -1|$SED -r "s/.*:\ \"|\",//g")
            if [ "$PROJECT_NAME" == "$REMOTE_PLUGIN_NAME" ];then
              printf "${LIGHT_GREEN}$APP_ID:)${NC} Avoid removing to itset.\n"
            else
              remove_dependency $PROJECT_PATH $REMOTE_PLUGIN_NAME $APP_ID
            fi
          else
            printf "${BROWN}$APP_ID:>${NC} REMOTE_PACKAGE_PATH [${RED}NOT FOUND${NC}]\n"
          fi
        fi
      done
    fi
  fi
}


# start with main code
init_env
init_cln
if [ -x $CLN_PROJECT_PATH/node_modules ]; then
  rm -rf $CLN_PROJECT_PATH/node_modules
fi
dependency_removal_check  "$CLN_PARENT_PATH" "$CLN_PROJECT_PATH" "$CLN_PROJECT_NAME" "$APP_ID"
end_cln
