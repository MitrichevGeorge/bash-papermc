#!/bin/bash

sudo -v || exit 1
set -e

echo "ВНИМАНИЕ!"
echo "Будет безвозвратно удалён сервер, плагины, миры и настройки."
echo
read -r -p "Для подтверждения введите YES: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Отмена."
    exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

SAVEPATH="$REAL_HOME/.papermc-geomit"
BASHRC_FILE="$REAL_HOME/.bashrc"

echo "Удаляем сервер из: $SAVEPATH"

if [ -d "$SAVEPATH" ]; then
    rm -rf "$SAVEPATH"
    echo "Папка удалена."
else
    echo "Папка не найдена."
fi

echo "Удаляем alias run-mc из .bashrc"

if [ -f "$BASHRC_FILE" ]; then
    sed -i "\|alias run-mc='$SAVEPATH/run.sh'|d" "$BASHRC_FILE"
    echo "Alias удалён."
fi

echo
echo "Готово."
echo "Перезапустите терминал или выполните:"
echo "source ~/.bashrc"