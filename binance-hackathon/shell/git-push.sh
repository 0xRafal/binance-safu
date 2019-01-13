#!/usr/bin/env bash
PSH_VERSION=0.1.21
PSH_UPDATE=2018-1-9
PSH_AUTHOR="Cloudgen Wong"
PSH_NAME=git-push.sh

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

function init_psh {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_7YK63=$APP_ID
    APP_ID="$APP_ID->"PSH
  else
    APP_ID=PSH
  fi
  PSH_SCRIPT=$($READLINK -f "$0")
  PSH_SCRIPTPATH=$(dirname "$PSH_SCRIPT")
  PSH_PROJECT_PATH=$(echo $PSH_SCRIPTPATH | $SED -e "s/\/shell//g" )
  PSH_PROJECT_NAME=$(cat $PSH_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PSH_PROJECT_VERSION=$(cat $PSH_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PSH_PROJECT_UPDATE=$(cat $PSH_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  PSH_PARENT_PATH=$(echo $PSH_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $PSH_PROJECT_PATH/shell/hello.sh "$PSH_VERSION" "$PSH_UPDATE" "$PSH_AUTHOR" "$APP_ID" "$PSH_NAME"

  if [ -f $PSH_PROJECT_PATH/meta/project-list.txt ]; then
    PROJECT_LIST=$(cat $PSH_PROJECT_PATH/meta/project-list.txt)
    PROJECT_LIST_NOT_FOUND=0
  else
    PROJECT_LIST_NOT_FOUND=1
  fi
  printf "${LIGHT_BLUE}$APP_ID:]${NC} Current plugin name: $PSH_PROJECT_NAME version $PSH_PROJECT_VERSION ($PSH_PROJECT_UPDATE) [${GREEN}OK${NC}]\n"
}

function end_psh {
  $PSH_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_7YK63 ]; then
    APP_ID=$OLD_APP_ID_7YK63
  fi
}

function git_push {
  if [ ! -z $1 ] && [ ! -z $2 ]; then
    PROJECT_PATH=$1
    PLUGIN=$2
    APP_ID=$3
    MSG=$4
    PLUGIN_PATH=$PROJECT_PATH/$PLUGIN
    README_PATH=$PLUGIN_PATH/README.md
    README_TEMP=$PLUGIN_PATH/.README.md.swp

    cd $PLUGIN_PATH && GIT_CLEAN=$(git status|grep clean| $SED -r "s/^.+\ //g")
    if [ "$GIT_CLEAN" == "clean" ]; then
      printf "${LIGHT_GREEN}$APP_ID:)${NC} Plugin '${BROWN}$PLUGIN${NC}' is clean [${BROWN}UNCHANGED${NC}]\n"
    else
      README_MSG=$(cat $README_PATH | grep -v "\#"|grep "Commit" |head -1| $SED -r "s/.*:\ +//g")
      $SED -r "s/$README_MSG/$MSG/g" $README_PATH > $README_TEMP
      rm $README_PATH
      mv $README_TEMP $README_PATH
      printf "${LIGHT_BLUE}$APP_ID:]${NC} Plugin '${BROWN}$PLUGIN${NC}' is modified and being [${GREEN}PUSHED${NC}] ...\n"
      cd $PLUGIN_PATH && source $PLUGIN_PATH/shell/commit.sh "$APP_ID"
    fi
  else
    printf "${BROWN}$APP_ID:>${NC} git_push parameter [${RED}NOT FOUND${NC}]\n"
  fi
}

# start with main code
init_env
init_psh
MSG="Update all shell scripts"
if [ ! -z "$1" ]; then
  MSG="$1"
fi
if [ "$PROJECT_LIST_NOT_FOUND" != "1" ]; then
  for PROJECT in $PROJECT_LIST
  do
    if [ ! -z $PROJECT ]; then
      git_push "$PSH_PROJECT_PATH" "$PROJECT" "$APP_ID" "$MSG"
    fi
  done
else
  printf "${BROWN}$APP_ID:>${NC} project-list.txt [${RED}NOT FOUND${NC}]\n"
fi
end_psh
