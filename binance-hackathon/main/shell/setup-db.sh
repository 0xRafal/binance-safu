#!/usr/bin/env bash
DBA_VERSION=0.1.16
DBA_UPDATE=2018-1-7
DBA_AUTHOR="Cloudgen Wong"
DBA_NAME=setup-db.sh

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

function init_dba {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_35D25=$APP_ID
    APP_ID="$APP_ID->"DBA
  else
    APP_ID=DBA
  fi
  DBA_SCRIPT=$($READLINK -f "$0")
  DBA_SCRIPTPATH=$(dirname "$DBA_SCRIPT")
  DBA_PROJECT_PATH=$(echo $DBA_SCRIPTPATH | $SED -e "s/\/shell//g" )
  DBA_PROJECT_NAME=$(cat $DBA_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  DBA_PROJECT_VERSION=$(cat $DBA_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  DBA_PROJECT_UPDATE=$(cat $DBA_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  DBA_PARENT_PATH=$(echo $DBA_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $DBA_PROJECT_PATH/shell/hello.sh "$DBA_VERSION" "$DBA_UPDATE" "$DBA_AUTHOR" "$APP_ID" "$DBA_NAME"

}

function end_dba {
  $DBA_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_35D25 ]; then
    APP_ID=$OLD_APP_ID_35D25
  fi
}

# start with main code
init_env
init_dba
if [ ! -z $DBA_PROJECT_PATH ]; then
  ENV_PATH=$DBA_PROJECT_PATH/.env
  if [ -f $ENV_PATH ]; then
    PORT=$(cat $ENV_PATH|grep PORT\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    NODE_ENV=$(cat $ENV_PATH|grep NODE_ENV\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    DB_PASS=$(cat $ENV_PATH|grep DEVELOPMENT_DB_PASSWORD\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    DEVELOPMENT_DB=$(cat $ENV_PATH|grep DEVELOPMENT_DB\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    DEVELOPMENT_DB_USER=$(cat $ENV_PATH|grep DEVELOPMENT_DB_USER\=|head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    MYSQL_SCRIPT_PATH="$DBA_PROJECT_PATH/setup-db/$NODE_ENV/*.sql"
    for f in $MYSQL_SCRIPT_PATH
    do
      FILENAME=$( echo $f | $SED -r "s/^.*\///g")
      $SED -r "s/--\s*/-- /g" $f > /tmp/$FILENAME
      mysql --user=$DEVELOPMENT_DB_USER --password=$DB_PASS $DEVELOPMENT_DB < /tmp/$FILENAME
      rm /tmp/$FILENAME
      printf "${LIGHT_GRAY}$APP_ID:]${NC}$f file [${GREEN}PROCESSED${NC}]\n"
    done
  else
    printf "${BROWN}$APP_ID:>${NC} .env [${RED}NOT FOUND${NC}]\n"
  fi
else
  printf "${BROWN}$APP_ID:>${NC} PROJECT_PATH [${RED}REQUIRED${NC}]\n"
fi
end_dba
