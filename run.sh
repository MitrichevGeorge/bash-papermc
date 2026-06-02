#!/bin/bash

SAVEPATH=$HOME/.papermc-geomit
cd $SAVEPATH
ADRESS=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
echo "Сервер будет доступен по локальной сети на $ADRESS"

java -Xms4G -Xmx4G \
  -Dlogin.plugin=openlogin \
  -XX:+UseZGC \
  -XX:+ZGenerational \
  -XX:+AlwaysPreTouch \
  -XX:+DisableExplicitGC \
  -XX:+PerfDisableSharedMem \
  -jar folia-1.20.4.jar nogui