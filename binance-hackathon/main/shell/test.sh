#!/usr/bin/env bash
TST_VERSION=0.1.25
TST_UPDATE=2018-1-9
TST_AUTHOR="Cloudgen Wong"
TST_NAME=test.sh

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

function init_tst {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_30E22=$APP_ID
    APP_ID="$APP_ID->"TST
  else
    APP_ID=TST
  fi
  TST_SCRIPT=$($READLINK -f "$0")
  TST_SCRIPTPATH=$(dirname "$TST_SCRIPT")
  TST_PROJECT_PATH=$(echo $TST_SCRIPTPATH | $SED -e "s/\/shell//g" )
  TST_PROJECT_NAME=$(cat $TST_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  TST_PROJECT_VERSION=$(cat $TST_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  TST_PROJECT_UPDATE=$(cat $TST_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  TST_PARENT_PATH=$(echo $TST_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $TST_PROJECT_PATH/shell/hello.sh "$TST_VERSION" "$TST_UPDATE" "$TST_AUTHOR" "$APP_ID" "$TST_NAME"
  printf "${LIGHT_BLUE}$APP_ID:]${NC} Current plugin name: $TST_PROJECT_NAME version $TST_PROJECT_VERSION ($TST_PROJECT_UPDATE) [${GREEN}OK${NC}]\n"

  if [ -f $TST_PROJECT_PATH/meta/project-list.txt ]; then
    PROJECT_LIST=$(cat $TST_PROJECT_PATH/meta/project-list.txt)
    PROJECT_LIST_NOT_FOUND=0
  else
    PROJECT_LIST_NOT_FOUND=1
  fi
  if [ -f $TST_PROJECT_PATH/meta/script-list.txt ]; then
    export SCRIPT_LIST=$(cat $TST_PROJECT_PATH/meta/script-list.txt)
  fi

  if [ -f $TST_PROJECT_PATH/.env ]; then
    echo "$APP_ID:) .env in current folder [FOUND]!"
    TST_ENV_PATH=$TST_PROJECT_PATH/.env
  else
    if [ -f $TST_PROJECT_PATH/main/.env ]; then
      echo "$APP_ID:) .env in 'main' [FOUND]!"
      TST_ENV_PATH=$TST_PROJECT_PATH/main/.env
    fi
  fi
}

function end_tst {
  $TST_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_30E22 ]; then
    APP_ID=$OLD_APP_ID_30E22
  fi
}


# start with main code
init_env
init_tst

if [ -x $TST_PROJECT_PATH/test ]; then
  source $TST_PROJECT_PATH/shell/envCheck.sh
  if [ ! -z "$ENV_PASS" ]; then
    cd $TST_PROJECT_PATH && source $TST_PROJECT_PATH/shell/gitCheck.sh
    cd $TST_PROJECT_PATH && source $TST_PROJECT_PATH/shell/dependency.sh "$TST_PARENT_PATH" "$TST_PROJECT_PATH" "$TST_PROJECT_NAME"

    if [ ! -z "$NPM" ]; then
      source $TST_PROJECT_PATH/shell/npm-install.sh
      if [ ! -x /usr/bin/mocha ]; then
        cd $TST_PROJECT_PATH && sudo $NPM install -g mocha
      fi
      CHAI_INSTALLATION=$($NPM list chai | grep chai)
      if [ -z  "$CHAI_INSTALLATION" ]; then
        cd $TST_PROJECT_PATH && $NPM install --save-dev chai
      fi
      CHAI_HTTP_INSTALLATION=$($NPM list chai | grep chai-http)
      if [ -z  "$CHAI_HTTP_INSTALLATION" ]; then
        cd $TST_PROJECT_PATH && $NPM install --save-dev chai-http
      fi
      if [ -x /usr/bin/mocha ]; then
        for TEST_FILE in $TST_PROJECT_PATH/test
        do
          cd $TST_PROJECT_PATH && mocha $TEST_FILE
        done
      fi
      if [ "$TST_PROJECT_NAME" != "Main" ]; then
        MAIN_PATH=$TST_PARENT_PATH/main
        MAIN_PACKAGE_PATH=$MAIN_PATH/node_modules
        if [ ! -z $MAIN_PACKAGE_PATH ]; then
          if [ -x $MAIN_PACKAGE_PATH ]; then
            cd $TST_PROJECT_PATH && source $TST_PROJECT_PATH/shell/clean.sh
          fi
        fi
      fi
    else
      printf "${BROWN}$APP_ID:>${NC} npm [${RED}NOT FOUND${NC}]\n"
    fi
  else
    printf "${BROWN}$APP_ID:>${NC} Project execution [${RED}FAILED${NC}]\n"
  fi
else
  printf "${BROWN}$APP_ID:>${NC} Test file(s) [${RED}NOT FOUND${NC}]\n"
fi
end_tst
if [ ! -z $OLD_APP_ID_30E22 ]; then
  APP_ID=$OLD_APP_ID_30E22
fi
