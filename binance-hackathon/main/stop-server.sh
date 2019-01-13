#!/bin/bash
if [ -f ./plugin.pid ]; then
  kill -9 $(cat ./plugin.pid)
fi
