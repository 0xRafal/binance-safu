#!/usr/bin/env bash
I2M_VERSION=0.1.12
I2M_UPDATE=2018-12-28
I2M_AUTHOR="Cloudgen Wong"
I2M_NAME=install2main.sh

function init_env {
  if [[ `uname` == 'Darwin' ]]; then
    READLINK=$( which greadlink )
    if [ -z "$READLINK" ]; then
      echo 'ERROR: GNU utils required for Mac. You may use homebrew to install them: brew install coreutils gnu-readlink'
      exit 1
    fi
    SED=$( which gsed )
    if [ -z "$SED" ]; then
      echo 'ERROR: GNU utils required for Mac. You may use homebrew to install them: brew install coreutils gnu-sed'
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

function init_i2m {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_3Y738=$APP_ID
    APP_ID="$APP_ID->"I2M
  else
    APP_ID=I2M
  fi
  I2M_SCRIPT=$($READLINK -f "$0")
  I2M_SCRIPTPATH=$(dirname "$I2M_SCRIPT")
  I2M_PROJECT_PATH=$(echo $I2M_SCRIPTPATH | $SED -e "s/\/shell//g" )
  I2M_PROJECT_NAME=$(cat $I2M_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  I2M_PROJECT_VERSION=$(cat $I2M_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  I2M_PROJECT_UPDATE=$(cat $I2M_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  I2M_PARENT_PATH=$(echo $I2M_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $I2M_PROJECT_PATH/shell/hello.sh "$I2M_VERSION" "$I2M_UPDATE" "$I2M_AUTHOR" "$APP_ID" "$I2M_NAME"

  echo "$APP_ID:] Current plugin name: $I2M_PROJECT_NAME version $I2M_PROJECT_VERSION ($I2M_PROJECT_UPDATE)"
}

function end_i2m {
  $I2M_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_3Y738 ]; then
    APP_ID=$OLD_APP_ID_3Y738
  fi
}

function install_to_main {
  if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ]; then
    PARENT_PATH=$1
    PROJECT_PATH=$2
    PROJECT_NAME=$3
    APP_ID=$4
    if [ ! -x $PROJECT_PATH ]; then
      echo "$APP_ID:> Current project path $PROJECT_PATH [NOT FOUND]"
    else
      LOCAL_PLUGIN_PATH=$PROJECT_PATH/plugins/$PROJECT_NAME
      LOCAL_PACKAGE=$PROJECT_PATH/package.json
      TARGET_PATH=$PARENT_PATH/main
      TARGET_PLUGIN_BASE=$TARGET_PATH/plugins
      TARGET_PLUGIN_PATH=$TARGET_PLUGIN_BASE/$PROJECT_NAME
      if [ ! -z $TARGET_PATH ]; then
        if [ -x $TARGET_PATH ]; then
          mkdir -p $TARGET_PLUGIN_BASE
          if [ ! -z $TARGET_PLUGIN_PATH ]; then
            if [ -x $TARGET_PLUGIN_PATH ]; then
              rm -rf $TARGET_PLUGIN_PATH
            fi
          fi
          cp -r $LOCAL_PLUGIN_PATH $TARGET_PLUGIN_BASE
          cp -r $LOCAL_PACKAGE $TARGET_PLUGIN_PATH
          echo "$APP_ID:) Plugin [$PROJECT_NAME] [SENT TO MAIN]"
        else
          echo "$APP_ID:> main -> $TARGET_PATH [NOT FOUND]"
        fi
      fi
    fi
  else
    echo "$APP_ID:> install_to_main parameter [MISSING]"
  fi
}

# start with main code
if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ]; then
  init_env
  init_i2m
  PARENT_PATH=$1
  PROJECT_PATH=$2
  PROJECT_NAME=$3
  install_to_main $PARENT_PATH $PROJECT_PATH $PROJECT_NAME $APP_ID
  end_i2m
else
  echo ":I2M:> install2main.sh [PARENT_PATH] [PROJECT_PATH] [PROJECT_NAME]"
fi
