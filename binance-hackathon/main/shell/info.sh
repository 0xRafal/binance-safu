#!/usr/bin/env bash
INF_VERSION=0.1.16
INF_UPDATE=2018-1-9
INF_AUTHOR="Cloudgen Wong"
INF_NAME=info.sh

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

function init_inf {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_32C4F=$APP_ID
    APP_ID="$APP_ID->"INF
  else
    APP_ID=INF
  fi
  INF_SCRIPT=$($READLINK -f "$0")
  INF_SCRIPTPATH=$(dirname "$INF_SCRIPT")
  INF_PROJECT_PATH=$(echo $INF_SCRIPTPATH | $SED -e "s/\/shell//g" )
  INF_PROJECT_NAME=$(cat $INF_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  INF_PROJECT_VERSION=$(cat $INF_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  INF_PROJECT_UPDATE=$(cat $INF_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  INF_PARENT_PATH=$(echo $INF_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  INF_GROUP_NAME=$(cat $INF_PROJECT_PATH/package.json |grep \"git-group-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  INF_SERVER_NAME=$(cat $INF_PROJECT_PATH/package.json |grep \"git-server-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  $INF_PROJECT_PATH/shell/hello.sh "$INF_VERSION" "$INF_UPDATE" "$INF_AUTHOR" "$APP_ID" "$INF_NAME"
  DEPENDENCIES=$(cat $INF_PROJECT_PATH/package.json | tr '\n' '\r' |$SED -r "s/.+\"dependencies\": \{\s*|\}.*//g"|$SED -r "s/\s*,\s*/,/g"| $SED -r "s/\s*:\s*/:/g"| tr "," "\n")
  echo "$APP_ID:) Dependency Lists: "
  for DEPENDENCY in $DEPENDENCIES
  do
    echo "$APP_ID:) ...  $DEPENDENCY"
  done
  if [ ! -z "$INF_SERVER_NAME" ]; then
    export GIT_SERVER_NAME="$INF_SERVER_NAME"
    echo "$APP_ID:) GIT_SERVER_NAME=$GIT_SERVER_NAME [FOUND]!"
  fi
  if [ ! -z "$INF_GROUP_NAME" ]; then
    export GIT_GROUP_NAME="$INF_GROUP_NAME"
    echo "$APP_ID:) GIT_GROUP_NAME=$GIT_GROUP_NAME [FOUND]!"
  fi
}

function end_inf {
  $INF_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_32C4F ]; then
    APP_ID=$OLD_APP_ID_32C4F
  fi
}

function main_inf {
  if [ ! -z "$INF_PARENT_PATH" ]; then
    if [ -x $INF_PARENT_PATH ]; then
      if [ -x $INF_PARENT_PATH/main ]; then
        export MAIN_PATH=$INF_PARENT_PATH/main
      fi
    fi
  fi
  if [ -f $INF_PROJECT_PATH/meta/project-list.txt ]; then
    export PROJECT_LIST=$(cat $INF_PROJECT_PATH/meta/project-list.txt)
  else
    export PROJECT_LIST_NOT_FOUND=1
  fi

  if [ -f $INF_PROJECT_PATH/meta/script-list.txt ]; then
    export SCRIPT_LIST=$(cat $INF_PROJECT_PATH/meta/script-list.txt)
  fi

  if [ -f $INF_PROJECT_PATH/.env ]; then
    echo "$APP_ID:) .env in current folder [FOUND]!"
    export ENV_PATH=$INF_PROJECT_PATH/.env
  else
    if [ -f $INF_PROJECT_PATH/main/.env ]; then
      echo "$APP_ID:) .env in 'main' [FOUND]!"
      export ENV_PATH=$INF_PROJECT_PATH/main/.env
    fi
  fi
  if [ ! -z $ENV_PATH ]; then
    if [ -f $ENV_PATH ]; then
        export PORT=$(cat $ENV_PATH|grep PORT\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        export NODE_ENV=$(cat $ENV_PATH|grep NODE_ENV\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        export DB_PASS=$(cat $ENV_PATH|grep DEVELOPMENT_DB_PASSWORD\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        export DEVELOPMENT_DB=$(cat $ENV_PATH|grep DEVELOPMENT_DB\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        export DEVELOPMENT_DB_USER=$(cat $ENV_PATH|grep DEVELOPMENT_DB_USER\=|head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    else
      echo "$APP_ID:> .env [NOT FOUND]!"
    fi
    echo "$APP_ID:) Environment: $NODE_ENV"
  else
    echo "$APP_ID:> .env [NOT FOUND]!"
  fi
  echo "$APP_ID:] Current plugin name: $INF_PROJECT_NAME version $INF_PROJECT_VERSION ($INF_PROJECT_UPDATE)"
}

# start with main code
init_env
init_inf
main_inf
end_inf
# end
