#!/usr/bin/env bash
DEP_VERSION=0.1.20
DEP_UPDATE=2018-1-7
DEP_AUTHOR="Cloudgen Wong"
DEP_NAME=dependency.sh

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

function init_dep {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_6DK23=$APP_ID
    APP_ID="$APP_ID->"DEP
  else
    APP_ID=DEP
  fi
  DEP_SCRIPT=$($READLINK -f "$0")
  DEP_SCRIPTPATH=$(dirname "$DEP_SCRIPT")
  DEP_PROJECT_PATH=$(echo $DEP_SCRIPTPATH | $SED -e "s/\/shell//g" )
  DEP_PROJECT_NAME=$(cat $DEP_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  DEP_PROJECT_VERSION=$(cat $DEP_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  DEP_PROJECT_UPDATE=$(cat $DEP_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  DEP_PARENT_PATH=$(echo $DEP_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $DEP_PROJECT_PATH/shell/hello.sh "$DEP_VERSION" "$DEP_UPDATE" "$DEP_AUTHOR" "$APP_ID" "$DEP_NAME"
  printf "${LIGHT_BLUE}$APP_ID:]${NC} Current plugin name: $DEP_PROJECT_NAME version $DEP_PROJECT_VERSION ($DEP_PROJECT_UPDATE)' [${GREEN}FOUND${NC}]\n"
}

function end_dep {
  $DEP_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_6DK23 ]; then
    APP_ID=$OLD_APP_ID_6DK23
  fi
}

function add_dependency {
  PARENT_PATH=$1
  PROJECT_PATH=$2
  DEPENDENCY_NAME=$3
  APP_ID=$4
  if [ ! -z $PARENT_PATH ] && [ ! -z $PROJECT_PATH ] && [ ! -z $DEPENDENCY_NAME ]; then
    REMOTE_PATH=$PARENT_PATH/$DEPENDENCY_NAME
    REMOTE_PACKAGE_PATH=$PARENT_PATH/$DEPENDENCY_NAME/package.json
    if [ ! -x $REMOTE_PACKAGE_PATH ]; then
      if [ ! -f $REMOTE_PACKAGE_PATH ]; then
        printf "${LIGHT_GREEN}$APP_ID:)${NC} Plugin '$REMOTE_PACKAGE_PATH', now download from git [${BROWN}NOT FOUND${NC}]\n"
        cd $PARENT_PATH && source $PROJECT_PATH/shell/gitCheck.sh gitlab.hex $DEPENDENCY_NAME
      fi
      if [ -f $REMOTE_PACKAGE_PATH ]; then
        mkdir -p $PROJECT_PATH/plugins/
        REMOTE_PLUGIN_NAME=$(cat $REMOTE_PACKAGE_PATH |grep \"name\" |head -1| sed -r "s/.*:\ \"|\",//g")
        REMOTE_PLUGIN_VERSION=$(cat $REMOTE_PACKAGE_PATH |grep \"version\" | head -1| sed -r "s/.*:\ \"|\",//g")
        if [ "$REMOTE_PLUGIN_NAME" != "Main" ]; then
          LOCAL_PLUGIN_BASE=$PROJECT_PATH/plugins
          LOCAL_PLUGIN_PATH=$LOCAL_PLUGIN_BASE/$REMOTE_PLUGIN_NAME
          REMOTE_PLUGIN_PATH=$REMOTE_PATH/plugins/$REMOTE_PLUGIN_NAME
          if [ -f $LOCAL_PLUGIN_PATH ]; then
            rm -rf $LOCAL_PLUGIN_PATH
          fi
          if [ -x $LOCAL_PLUGIN_PATH ]; then
            rm -rf $LOCAL_PLUGIN_PATH
          fi
          cp -r $REMOTE_PLUGIN_PATH $LOCAL_PLUGIN_BASE
          cp  $REMOTE_PACKAGE_PATH $LOCAL_PLUGIN_PATH
          printf "${LIGHT_BLUE}$APP_ID:]${NC} Dependency [$REMOTE_PLUGIN_NAME($REMOTE_PLUGIN_VERSION)] in $1 [${GREEN}INSTALLED${NC}]\n"
        fi
      fi
    fi
  fi
}

function dependency_check {
  PARENT_PATH=$1
  PROJECT_PATH=$2
  PROJECT_NAME=$3
  APP_ID=$4
  if [ ! -z $PARENT_PATH ] && [ ! -z $PROJECT_PATH ] && [ ! -z $PROJECT_NAME ]; then
    PACKAGE_JSON=$PROJECT_PATH/package.json
    if [ -f $PACKAGE_JSON ]; then
      PLUGIN_DEPENDENCIES=$(cat $PACKAGE_JSON |grep \"plugin-dependencies\" | head -1| sed -r "s/\ *,\ */,/g" | $SED -r "s/.*:\ \"|\",//g")
      if [ "$PROJECT_NAME" == "Main" ]; then
        printf "${LIGHT_GREEN}$APP_ID:)${NC} This is Main Project, plugin folder [${BROWN}RESET${NC}]\n"
        rm -rf $PROJECT_PATH/plugins
        mkdir $PROJECT_PATH/plugins
      fi
      DEPENDENCY_NAMES=$(echo $PLUGIN_DEPENDENCIES|tr "," "\n")
      for DEPENDENCY_NAME in $DEPENDENCY_NAMES
      do
        if [ "$PROJECT_NAME" == "$DEPENDENCY_NAME" ];then
          printf "${LIGHT_GREEN}$APP_ID:)${NC} Avoid copying to itset.\n"
        else
          add_dependency $PARENT_PATH $PROJECT_PATH $DEPENDENCY_NAME $APP_ID
        fi
      done
    else
      printf "${BROWN}$APP_ID:>${NC} Local Package.json $PACKAGE_JSON [${RED}NOT FOUND${NC}]\n"
    fi
  fi
}

init_env
init_dep
# start with main code
if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ]; then
  PARENT_PATH=$1
  PROJECT_PATH=$2
  PROJECT_NAME=$3
  dependency_check $PARENT_PATH $PROJECT_PATH $PROJECT_NAME $APP_ID
  end_dep
else
  printf "${BROWN}$APP_ID:>${NC} dependency.sh parameters [${RED}MISSING${NC}]\n"
fi
