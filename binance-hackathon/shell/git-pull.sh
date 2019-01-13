#!/usr/bin/env bash
PUL_VERSION=0.1.16
PUL_UPDATE=2018-1-9
PUL_AUTHOR="Cloudgen Wong"
PUL_NAME=git-pull.sh

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

function init_pul {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_6DK23=$APP_ID
    APP_ID="$APP_ID->"PUL
  else
    APP_ID=PUL
  fi
  PUL_SCRIPT=$($READLINK -f "$0")
  PUL_SCRIPTPATH=$(dirname "$PUL_SCRIPT")
  PUL_PROJECT_PATH=$(echo $PUL_SCRIPTPATH | $SED -e "s/\/shell//g" )
  PUL_PROJECT_NAME=$(cat $PUL_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PUL_PROJECT_VERSION=$(cat $PUL_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PUL_PROJECT_UPDATE=$(cat $PUL_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PUL_PARENT_PATH=$(echo $PUL_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $PUL_PROJECT_PATH/shell/hello.sh "$PUL_VERSION" "$PUL_UPDATE" "$PUL_AUTHOR" "$APP_ID" "$PUL_NAME"

  if [ -f $PUL_PROJECT_PATH/meta/project-list.txt ]; then
    PROJECT_LIST=$(cat $PUL_PROJECT_PATH/meta/project-list.txt)
    PROJECT_LIST_NOT_FOUND=0
  else
    PROJECT_LIST_NOT_FOUND=1
  fi
  printf "${LIGHT_BLUE}$APP_ID:]${NC} Current plugin name: $PUL_PROJECT_NAME version $PUL_PROJECT_VERSION ($PUL_PROJECT_UPDATE) [${GREEN}OK${NC}]\n"
}

function end_pul {
  $PUL_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_6DK23 ]; then
    APP_ID=$OLD_APP_ID_6DK23
  fi
}

function git_pull {
  if [ ! -z $1 ] && [ ! -z $2 ]; then
    PROJECT_PATH=$1
    PLUGIN=$2
    APP_ID=$3
    PLUGIN_PATH=$PROJECT_PATH/$PLUGIN
    cd $PLUGIN_PATH && GIT_CLEAN=$(git status|grep clean| $SED -r "s/^.+\ //g")
    if [ "$GIT_CLEAN" == "clean" ]; then
      cd $PLUGIN_PATH && git reset --hard 2>&1 > /dev/null
      cd $PLUGIN_PATH && git pull origin master
      printf "${LIGHT_BLUE}$APP_ID:]${NC} Plugin '${BROWN}$PLUGIN${NC}' [${GREEN}UPDATED${NC}]\n"
    else
      printf "${BROWN}$APP_ID:>${NC} Plugin '${BROWN}$PLUGIN${NC}' GIT [${RED}NOT CLEAN${NC}]\n"
      printf "${BROWN}$APP_ID:]${NC} Need to handle it manually!\n"
    fi
  else
    printf "${BROWN}$APP_ID:>${NC} git_pull parameter [${RED}NOT FOUND${NC}]\n"
  fi
}

# start with main code
init_env
init_pul

if [ "$PROJECT_LIST_NOT_FOUND" != "1" ]; then
  for PROJECT in $PROJECT_LIST
  do
    if [ ! -z $PROJECT ]; then
      git_pull $PUL_PROJECT_PATH $PROJECT $APP_ID
    fi
  done
else
  printf "${BROWN}$APP_ID:>${NC} project-list.txt [${RED}NOT FOUND${NC}]\n"
fi
end_pul
