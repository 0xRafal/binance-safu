#!/usr/bin/env bash
SET_VERSION=0.1.17
SET_UPDATE=2018-1-9
SET_AUTHOR="Cloudgen Wong"
SET_NAME=setup.sh

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

function init_set {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_36C23=$APP_ID
    APP_ID="$APP_ID->"SET
  else
    APP_ID=SET
  fi
  SET_SCRIPT=$($READLINK -f "$0")
  SET_SCRIPTPATH=$(dirname "$SET_SCRIPT")
  SET_PROJECT_PATH=$(echo $SET_SCRIPTPATH | $SED -e "s/\/shell//g" )
  SET_PROJECT_NAME=$(cat $SET_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  SET_PROJECT_VERSION=$(cat $SET_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  SET_PROJECT_UPDATE=$(cat $SET_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  SET_PARENT_PATH=$(echo $SET_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  SET_GROUP_NAME=$(cat $SET_PROJECT_PATH/meta/package.json |grep \"git-group-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  SET_SERVER_NAME=$(cat $SET_PROJECT_PATH/meta/package.json |grep \"git-server-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")

  $SET_PROJECT_PATH/shell/hello.sh "$SET_VERSION" "$SET_UPDATE" "$SET_AUTHOR" "$APP_ID" "$SET_NAME"

  if [ -f $SET_PROJECT_PATH/meta/project-list.txt ]; then
    PROJECT_LIST=$(cat $SET_PROJECT_PATH/meta/project-list.txt)
    PROJECT_LIST_NOT_FOUND=0
  else
    PROJECT_LIST_NOT_FOUND=1
  fi
  printf "${LIGHT_BLUE}$APP_ID:]${NC}  Current plugin name: $SET_PROJECT_NAME version $SET_PROJECT_VERSION ($SET_PROJECT_UPDATE) [${GREEN}OK${NC}]\n"

  if [ -f $SET_PROJECT_PATH/.env ]; then
    printf "${LIGHT_GRAY}$APP_ID:]${NC} .env in current folder [${GREEN}FOUND${NC}]\n"
    SET_ENV_PATH=$SET_PROJECT_PATH/.env
  else
    if [ -f $SET_PROJECT_PATH/main/.env ]; then
      printf "${LIGHT_GRAY}$APP_ID:]${NC} .env in 'main' [${GREEN}FOUND${NC}]\n"
      SET_ENV_PATH=$SET_PROJECT_PATH/main/.env
    fi
  fi
}

function end_set {
  $SET_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_36C23 ]; then
    APP_ID=$OLD_APP_ID_36C23
  fi
}

# start with main code
init_env
init_set
if [ -z "SET_SERVER_NAME" ]; then
  SET_SERVER_NAME=gitlab.hex
else
  printf "${LIGHT_GRAY}$APP_ID:]${NC} Git-Server-Name: '$SET_SERVER_NAME' [${GREEN}FOUND${NC}]\n"
fi
if [ -z "SET_GROUP_NAME" ]; then
  SET_GROUP_NAME=open-api
else
  printf "${LIGHT_GRAY}$APP_ID:]${NC} Git-Group-Name: '$SET_GROUP_NAME' [${GREEN}FOUND${NC}]\n"
fi
if [ "$PROJECT_LIST_NOT_FOUND" != "1" ]; then
  # Start loop for each project
  for PROJECT in $PROJECT_LIST
  do
    if [ ! -x $SET_PROJECT_PATH/$PROJECT ]; then
      source ./shell/gitCheck.sh "$SET_SERVER_NAME" "$PROJECT" "$SET_GROUP_NAME"
    else
      printf "${LIGHT_GREEN}$APP_ID:)${NC} folder '$SET_PROJECT_PATH/$PROJECT' [${BROWN}EXISTS${NC}]\n"
      echo "$APP_ID:> folder $SET_PROJECT_PATH/$PROJECT [EXISTS]!"
    fi
  done

  if [ ! -z "$SET_ENV_PATH" ] && [ -f $SET_ENV_PATH ]; then
    PORT=$(cat $SET_ENV_PATH|grep PORT\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    NODE_ENV=$(cat $SET_ENV_PATH|grep NODE_ENV\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    if [ ! -z "$PORT" ]; then
      TEST_PORT=$(( $PORT + 1 ))
      ENV_TEST=$(cat $SET_ENV_PATH| $SED -r "s/PORT=/# PORT=/")
      echo "$APP_ID:] PORT $PORT will be used as main service..."
      echo "$APP_ID:] PORT $TEST_PORT will be used as testing..."
      cd main && $NPM install
      for PROJECT in $PROJECT_LIST
      do
        if [ "$PROJECT" != "main" ]; then
          cat  > $SET_PROJECT_PATH/$PROJECT/.env<<EOT
# Test Port should be different from normal PORT
PORT=$TEST_PORT
$ENV_TEST
# End
EOT
          #cp -r node_modules $PROJECT_PATH/$PROJECT/
          # remove the cross link generated from main projects
          #rm -rf $PROJECT_PATH/$PROJECT/node_modules/.bin
          # run npm install again to re-generate cross links.
          #cd $PROJECT_PATH/$PROJECT && npm install
          echo "$APP_ID:] setting up $PROJECT [DONE]!"
        else
          if [ ! -f $SET_PROJECT_PATH/$PROJECT/.env ]; then
            cp $SET_ENV_PATH $SET_PROJECT_PATH/$PROJECT/
          fi
        fi
      done

      #for PROJECT in $PROJECT_LIST
      #do
        #cd $PROJECT_PATH/$PROJECT && npm test
      #done
    else
      echo "$APP_ID:> Please set up a PORT number in .env"
    fi
  else
    echo "$APP_ID:> Please create a $SET_PROJECT_PATH/.env first!"
  fi
  # End Project loop
else
  echo "$APP_ID:> project-list.txt [NOT FOUND]!"
fi
end_set
