#!/usr/bin/env bash

DAR_VERSION=0.1.3
DAR_UPDATE=2018-12-28
DAR_AUTHOR="Cloudgen Wong"


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

# start with main code
init_env
