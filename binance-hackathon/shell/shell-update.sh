#!/usr/bin/env bash
UPD_VERSION=0.1.25
UPD_UPDATE=2018-1-9
UPD_AUTHOR="Cloudgen Wong"
UPD_NAME=shell-update.sh

#
# shell-update.sh
#
# Example: npm run update-projects
#
# Example: shell/shell-update.sh
#
#

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

function init_upd {
  if [ ! -z $APP_ID ]; then
    OLD_APP_ID_36C23=$APP_ID
    APP_ID="$APP_ID->"UPD
  else
    APP_ID=UPD
  fi
  UPD_SCRIPT=$($READLINK -f "$0")
  UPD_SCRIPTPATH=$(dirname "$UPD_SCRIPT")
  UPD_PROJECT_PATH=$(echo $UPD_SCRIPTPATH | $SED -e "s/\/shell//g" )
  UPD_PROJECT_NAME=$(cat $UPD_PROJECT_PATH/package.json |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  UPD_PROJECT_VERSION=$(cat $UPD_PROJECT_PATH/package.json |grep \"version\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  UPD_PROJECT_UPDATE=$(cat $UPD_PROJECT_PATH/package.json |grep \"update\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  UPD_PARENT_PATH=$(echo $UPD_PROJECT_PATH | $SED -r "s/\/[^\/]+$//" )
  $UPD_PROJECT_PATH/shell/hello.sh "$UPD_VERSION" "$UPD_UPDATE" "$UPD_AUTHOR" "$APP_ID" "$UPD_NAME"
  UPD_GROUP_NAME=$(cat $UPD_PROJECT_PATH/meta/package.json |grep \"git-group-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  UPD_SERVER_NAME=$(cat $UPD_PROJECT_PATH/meta/package.json |grep \"git-server-name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  DEPENDENCIES=$(cat $UPD_PROJECT_PATH/meta/package.json | tr '\n' '\r' |$SED -r "s/.+\"dependencies\": \{\s*|\}.*//g"|$SED -r "s/\s*,\s*/,/g"| $SED -r "s/\s*:\s*/:/g"| tr "," "\n")
  DEV_DEPENDENCIES=$(cat $UPD_PROJECT_PATH/meta/package.json | tr '\n' '\r' |$SED -r "s/.+\"devDependencies\": \{\s*|\}.*//g"|$SED -r "s/\s*,\s*/,/g"| $SED -r "s/\s*:\s*/:/g"| tr "," "\n")
  printf "${LIGHT_BLUE}$APP_ID:]${NC} Dependency Lists: $EXE_PROJECT_PATH [${GREEN}FOUND${NC}]\n"
  for DEPENDENCY in $DEPENDENCIES
  do
    printf "${LIGHT_BLUE}$APP_ID:]${NC} ...  $DEPENDENCY\n"
    LAST_DEPENDENCY=$DEPENDENCY
  done
  printf "${LIGHT_BLUE}$APP_ID:]${NC} devDependency Lists: $EXE_PROJECT_PATH [${GREEN}FOUND${NC}]\n"
  for DEPENDENCY in $DEV_DEPENDENCIES
  do
    printf "${LIGHT_BLUE}$APP_ID:]${NC} ...  $DEPENDENCY\n"
    LAST_DEV_DEPENDENCY=$DEPENDENCY
  done

  if [ ! -z "$UPD_SERVER_NAME" ]; then
    export GIT_SERVER_NAME="$UPD_SERVER_NAME"
    printf "${LIGHT_BLUE}$APP_ID:]${NC} GIT_SERVER_NAME=$GIT_SERVER_NAME [${GREEN}FOUND${NC}]\n"
  fi
  if [ ! -z "$UPD_GROUP_NAME" ]; then
    export GIT_GROUP_NAME="$UPD_GROUP_NAME"
    printf "${LIGHT_BLUE}$APP_ID:]${NC} GIT_GROUP_NAME=$GIT_GROUP_NAME [${GREEN}FOUND${NC}]\n"
  fi

  printf "${LIGHT_BLUE}$APP_ID:]${NC} Current plugin name: $UPD_PROJECT_NAME version $UPD_PROJECT_VERSION ($UPD_PROJECT_UPDATE) [${GREEN}FOUND${NC}]\n"

  if [ -f $UPD_PROJECT_PATH/meta/project-list.txt ]; then
    PROJECT_LIST=$(cat $UPD_PROJECT_PATH/meta/project-list.txt)
    PROJECT_LIST_NOT_FOUND=0
  else
    PROJECT_LIST_NOT_FOUND=1
  fi
  if [ -f $UPD_PROJECT_PATH/meta/script-list.txt ]; then
    export SCRIPT_LIST=$(cat $UPD_PROJECT_PATH/meta/script-list.txt)
  fi

  if [ -f $UPD_PROJECT_PATH/.env ]; then
    printf "${LIGHT_BLUE}$APP_ID:]${NC} .env in current folder [${GREEN}FOUND${NC}]\n"
    UPD_ENV_PATH=$UPD_PROJECT_PATH/.env
  else
    if [ -f $UPD_PROJECT_PATH/main/.env ]; then
      printf "${LIGHT_BLUE}$APP_ID:]${NC} .env in 'main' [${GREEN}FOUND${NC}]\n"
      UPD_ENV_PATH=$UPD_PROJECT_PATH/main/.env
    fi
  fi
  echo "$APP_ID:] "
}

function end_upd {
  $UPD_PROJECT_PATH/shell/bye.sh $APP_ID
  if [ ! -z $OLD_APP_ID_36C23 ]; then
    APP_ID=$OLD_APP_ID_36C23
  fi
}

function update_gitignore {
  GITIGNORE_SOURCE=$1
  PACKAGE_PATH=$2
  GITIGNORE_TARGET=$3
  PROJECT_NAME=$(cat $PACKAGE_PATH |grep \"name\" |head -1| $SED -r "s/.*:\ \"|\",//g")
  if [ "$PROJECT_NAME" == "Main" ]; then
    $SED -r "s/#plugins/plugins/g" $GITIGNORE_SOURCE > $GITIGNORE_TARGET
  else
    $SED -r "s/plugins\/$PROJECT_NAME/#plugins\/$PROJECT_NAME/g" $GITIGNORE_SOURCE > $GITIGNORE_TARGET
  fi
}

function update_package_json {
  PACKAGE="$1"
  PACKAGE2="$1.bak"
  GIT_SERVER_NAME="$2"
  GIT_GROUP_NAME="$3"
  TEXT=$(cat $PACKAGE | tr '\n' '\r' |$SED -r "s/\s*\"git-(group|server)-name\"\s*:[^,]+,\r//g" | $SED -r "s/\s*\"dependencies\"\s*:[^}]+}\s*,\s*\r/\r  \"dependencies\": {\r  },\r/g")
  echo $"$TEXT" | $SED -r "s/(.*\"dependencies\":[^\r]+).*/\1/"| tr "\r" "\n" > $PACKAGE2
  for DEPENDENCY in $DEPENDENCIES
  do
    if [ "$LAST_DEPENDENCY" == "$DEPENDENCY" ];then
      echo $"    $DEPENDENCY" >> $PACKAGE2
    else
      echo $"    $DEPENDENCY," >> $PACKAGE2
    fi
  done
  echo $"  }," >> $PACKAGE2
  echo $"  \"git-group-name\": \"$GIT_GROUP_NAME\"," >> $PACKAGE2
  echo $"  \"git-server-name\": \"$GIT_SERVER_NAME\"," >> $PACKAGE2
  echo $"  \"devDependencies\": {" >> $PACKAGE2
  for DEPENDENCY in $DEV_DEPENDENCIES
  do
    if [ "$LAST_DEV_DEPENDENCY" == "$DEPENDENCY" ];then
      echo $"    $DEPENDENCY" >> $PACKAGE2
    else
      echo $"    $DEPENDENCY," >> $PACKAGE2
    fi
  done
  echo $"  }" >> $PACKAGE2
  echo $"}" >> $PACKAGE2
  rm $PACKAGE
  mv $PACKAGE2 $PACKAGE
  printf "${LIGHT_BLUE}$APP_ID:]${NC} package at $PACKAGE [${GREEN}UPDATED${NC}]\n"
}

function update_plugin {
  if [ ! -z $1 ] && [ ! -z $2 ]; then
    PROJECT_PATH=$1
    PLUGIN=$2
    APP_ID=$3
    PLUGIN_PATH=$PROJECT_PATH/$PLUGIN
    META_PATH=$PLUGIN_PATH/meta/
    SHELL_PATH=$PLUGIN_PATH/shell/
    GIT_SERVER_NAME=$4
    GIT_GROUP_NAME=$5
    mkdir -p $META_PATH
    mkdir -p $SHELL_PATH
    for SCRIPT in $SCRIPT_LIST
    do
      if [ -f $PROJECT_PATH/$SCRIPT ]; then
        SUB_PATH=$(echo $SCRIPT|$SED -r "s/[^/]+$//g")
        cp $PROJECT_PATH/$SCRIPT $PLUGIN_PATH/$SUB_PATH
      else
        printf "${BROWN}$APP_ID:>${NC} script $PROJECT_PATH/$SCRIPT [${RED}NOT FOUND${NC}]\n"
      fi
    done
    chmod +x $SHELL_PATH -R
    if [ -f $PROJECT_PATH/$PLUGIN/env.sample ]; then
      rm $PROJECT_PATH/$PLUGIN/env.sample
    fi
    cp $PROJECT_PATH/meta/env-sample.txt $PROJECT_PATH/$PLUGIN/env.sample
    if [ -x $PROJECT_PATH/$PLUGIN/log ]; then
      cd $PROJECT_PATH/$PLUGIN && rm -rf log
      printf "${BROWN}$APP_ID:)${NC} Old log folder $PROJECT_PATH/$PLUGIN/log [${BROWN}REMOVED${NC}]\n"
    fi
    LOG_FOLDERS=$(cat $UPD_PROJECT_PATH/meta/log-structure.txt)
    for LOG_DIR in $LOG_FOLDERS
    do
      cd $PROJECT_PATH/$PLUGIN && mkdir -p log/$LOG_DIR
      cd $PROJECT_PATH/$PLUGIN && touch log/$LOG_DIR/keep
      printf "${LIGHT_BLUE}$APP_ID:]${NC} Log folder log/$LOG_DIR [${GREEN}created${NC}]\n"
    done
    update_gitignore "$PROJECT_PATH/meta/gitignore-template.txt" "$PROJECT_PATH/$PLUGIN/package.json" "$PROJECT_PATH/$PLUGIN/.gitignore"
    update_package_json "$PROJECT_PATH/$PLUGIN/package.json" "$GIT_SERVER_NAME" "$GIT_GROUP_NAME"
    printf "${LIGHT_BLUE}$APP_ID:]${NC} Plugin $PLUGIN [${GREEN}UPDATED${NC}]\n"
  else
    printf "${BROWN}$APP_ID:>${NC} update_plugin parameter [${RED}NOT FOUND${NC}]\n"
  fi
}

# start with main code
init_env
init_upd

if [ "$PROJECT_LIST_NOT_FOUND" != "1" ]; then
  for PROJECT in $PROJECT_LIST
  do
    if [ ! -z $PROJECT ]; then
      update_plugin "$UPD_PROJECT_PATH" "$PROJECT" "$APP_ID" "$GIT_SERVER_NAME" "$GIT_GROUP_NAME"
    fi
  done
  update_plugin "$UPD_PROJECT_PATH" "blank-plugin" "$APP_ID" "$GIT_SERVER_NAME" "$GIT_GROUP_NAME"
  update_plugin "$UPD_PROJECT_PATH" "main" "$APP_ID" "$GIT_SERVER_NAME" "$GIT_GROUP_NAME"
else
  printf "${BROWN}$APP_ID:>${NC}project-list.txt [${RED}NOT FOUND${NC}]\n"
fi
end_upd
