#!/usr/bin/env bash
CMT_VERSION=0.1.19
CMT_UPDATE=2018-1-7
CMT_AUTHOR="Cloudgen Wong"
CMT_NAME=commit.sh

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

function init_cmt {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_18D2A=$APP_ID
    APP_ID="$APP_ID->"CMT
  else
    APP_ID=CMT
  fi
  CMT_SCRIPT=$($READLINK -f "$0")
  CMT_SCRIPTPATH=$(dirname "$CMT_SCRIPT")
  CMT_PROJECT_PATH=$(echo $CMT_SCRIPTPATH | $SED -e "s/\/shell//g" )
  CMT_PROJECT_NAME=$(cat $CMT_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  CMT_PROJECT_VERSION=$(cat $CMT_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  CMT_PROJECT_UPDATE=$(cat $CMT_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  CMT_PARENT_PATH=$(echo $CMT_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $CMT_PROJECT_PATH/shell/hello.sh "$CMT_VERSION" "$CMT_UPDATE" "$CMT_AUTHOR" "$APP_ID" "$CMT_NAME"
}

function end_cmt {
  $CMT_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_18D2A ]; then
    APP_ID=$OLD_APP_ID_18D2A
  fi
}

function update_package {
  if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ]; then
    PROJECT_PATH=$1
    NEW_PROJECT_VERSION=$2
    NOW=$3
    APP_ID=$4
    $SED -r "s/\"version\":\s+\"[^\"]+/\"version\": \"$NEW_PROJECT_VERSION/g" $PROJECT_PATH/package.json > $PROJECT_PATH/.package.1.swp
    $SED -r "s/\"update\":\s+\"[^\"]+/\"update\": \"$NOW/g" $PROJECT_PATH/.package.1.swp > $PROJECT_PATH/.package.2.swp
    rm $PROJECT_PATH/package.json
    mv $PROJECT_PATH/.package.2.swp $PROJECT_PATH/package.json
    rm $PROJECT_PATH/.package.*
  else
    printf "${BROWN}$APP_ID:>${NC} update_package parameter [${RED}NOT FOUND${NC}]\n"
  fi
}

# start with main code
init_env
init_cmt

source $CMT_PROJECT_PATH/shell/new-version.sh "$CMT_PROJECT_VERSION"
if [ -z "$2" ]; then
  README_MSG=$(cat $CMT_PROJECT_PATH/README.md | grep -v "\#"|grep "Commit" |head -1|$SED -r "s/.*:\ +//g")
  COMMIT_MSG="$NEW_PROJECT_VERSION $README_MSG"
else
  COMMIT_MSG="$NEW_PROJECT_VERSION $2"
fi
NOW=$(date +'%Y-%m-%d')
printf "${LIGHT_BLUE}$APP_ID:]${NC} Commit Message: '${BROWN}$COMMIT_MSG${NC}' [${GREEN}OK${NC}]\n"
update_package $CMT_PROJECT_PATH $NEW_PROJECT_VERSION $NOW $APP_ID

cd $CMT_PROJECT_PATH && git add .
cd $CMT_PROJECT_PATH && git commit -m "$COMMIT_MSG"
cd $CMT_PROJECT_PATH && git push origin master
end_cmt
