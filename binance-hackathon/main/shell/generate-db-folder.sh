#!/usr/bin/env bash
GEN_VERSION=0.1.7
GEN_UPDATE=2018-10-26
GEN_AUTHOR="Cloudgen Wong"
GEN_NAME=generate-db-folder.sh

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
}

function init_gen {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_18K22=$APP_ID
    APP_ID="$APP_ID->"INF
  else
    APP_ID=INF
  fi
  GEN_SCRIPT=$($READLINK -f "$0")
  GEN_SCRIPTPATH=$(dirname "$GEN_SCRIPT")
  GEN_PROJECT_PATH=$(echo $GEN_SCRIPTPATH | $SED -e "s/\/shell//g" )
  GEN_PROJECT_NAME=$(cat $GEN_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GEN_PROJECT_VERSION=$(cat $GEN_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GEN_PROJECT_UPDATE=$(cat $GEN_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  GEN_PARENT_PATH=$(echo $GEN_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $GEN_PROJECT_PATH/shell/hello.sh "$GEN_VERSION" "$GEN_UPDATE" "$GEN_AUTHOR" "$APP_ID" "$GEN_NAME"

  if [ -f $GEN_PROJECT_PATH/.env ]; then
    echo "$APP_ID:) .env in current folder [FOUND]!"
    ENV_PATH=$GEN_PROJECT_PATH/.env
  else
    if [ -f $GEN_PROJECT_PATH/main/.env ]; then
      echo "$APP_ID:) .env in 'main' [FOUND]!"
      ENV_PATH=$GEN_PROJECT_PATH/main/.env
    fi
  fi
  if [ ! -z $ENV_PATH ]; then
    if [ -f $ENV_PATH ]; then
        PORT=$(cat $ENV_PATH|grep PORT\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        NODE_ENV=$(cat $ENV_PATH|grep NODE_ENV\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        DB_PASS=$(cat $ENV_PATH|grep DEVELOPMENT_DB_PASSWORD\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        DEVELOPMENT_DB=$(cat $ENV_PATH|grep DEVELOPMENT_DB\=| head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
        DEVELOPMENT_DB_USER=$(cat $ENV_PATH|grep DEVELOPMENT_DB_USER\=|head -1| $SED -r "s/^[^=]+=\s*|\*$//g")
    else
      echo "$APP_ID:> $ENV_PATH [NOT FOUND]!"
    fi
    echo "$APP_ID:) Environment: $NODE_ENV"
  else
    echo "$APP_ID:> .env [NOT FOUND]!"
  fi
  echo "$APP_ID:] Current plugin name: $GEN_PROJECT_NAME version $GEN_PROJECT_VERSION ($GEN_PROJECT_UPDATE)"
}

function end_gen {
  $GEN_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_18K22 ]; then
    APP_ID=$OLD_APP_ID_18K22
  fi
}

function copy_db_to_folder {
  if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ]; then
    SOURCE=$1
    DB_TARGET_PATH=$2
    ENVIRONMENT=$3
    TIME_STAMP=$( date +%s )
    TEMP_FILE=/tmp/$TIME_STAMP
    FILE_NAME=$( echo $SOURCE| $SED -r "s/^.+\///")
    echo ") Copying... $SOURCE to $DB_TARGET_PATH"
    $SED -r "s/Environment:.+$/Environment: $ENVIRONMENT/g" $SOURCE > $TEMP_FILE
    cp $TEMP_FILE $DB_TARGET_PATH/$FILE_NAME
  fi
}

# start with main code
init_env
init_gen

MYSQL_SCRIPT_PATH="$GEN_PROJECT_PATH/setup-db/$NODE_ENV/*.sql"
mkdir -p $GEN_PROJECT_PATH/setup-db/alpha
mkdir -p $GEN_PROJECT_PATH/setup-db/beta
mkdir -p $GEN_PROJECT_PATH/setup-db/integration
for f in $MYSQL_SCRIPT_PATH
do
  copy_db_to_folder "$f" "$GEN_PROJECT_PATH/setup-db/alpha" Alpha
  copy_db_to_folder "$f" "$GEN_PROJECT_PATH/setup-db/beta" Beta
  copy_db_to_folder "$f" "$GEN_PROJECT_PATH/setup-db/integration" Integration 
done
end_gen
