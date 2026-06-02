#!/bin/bash

sudo -v || exit 1

NOCONFIRM=false
if [[ "$1" == "--noconfirm" ]]; then
    NOCONFIRM=true
fi

SAVEPATH="~/.papermc-geomit"
FILENAME="folia-1.20.4.jar"

confirm() {
    if [ "$NOCONFIRM" = true ]; then
        return 0
    fi

    if [ ! -t 0 ]; then
        echo "Ошибка: Скрипт ожидает ввода, но терминал недоступен. Используйте --noconfirm." >&2
        return 1
    fi

    local prompt="${1:-Вы уверены?} [Y/n]: "
    local response

    while true; do
        read -r -p "$prompt" response
        
        response="${response,,}" 
        
        case "$response" in
            ""|"y"|"yes")
                return 0
                ;;
            "n"|"no")
                return 1
                ;;
            *)
                echo "Пожалуйста, введите 'y' (да) или 'n' (нет)."
                ;;
        esac
    done
}

if [ -f /etc/os-release ]; then

    . /etc/os-release
    echo "Обнаруженная ос: $NAME"
    
    echo "[1] Установка зависимостей ..."
    case "$ID" in
        ubuntu|debian)
            if confirm "Обновить пакеты?"; then
                sudo apt update -y
                sudo apt upgarde -y
            fi
            sudo apt install openjdk-21-jre-headless jq
            ;;
        centos|rhel|fedora)
            if confirm "Обновить пакеты?"; then
                sudo dnf update -y
                sudo dnf upgarde -y
            fi
            sudo dnf install openjdk-21-jre-headless jq
            ;;
        arch)
            if confirm "Обновить пакеты?"; then
                sudo pacman -Syu --noconfirm
            fi
            sudo pacman -S --noconfirm jre21-openjdk-headless jq
            ;;
        *)
            echo "Неизвестная os"
            exit 1
            ;;
    esac

    mkdir $SAVEPATH
    cd $SAVEPATH

    echo "[2] Скачиваем folia 1.20.4 ..."
    wget "https://api.papermc.io/v2/projects/folia/versions/1.20.4/builds/26/downloads/folia-1.20.4-26.jar" -O $FILENAME

    echo "[3] Первый запук ..."
    java -jar folia-26.1.jar nogui $FILENAME
    echo "eula=true" > eula.txt

    echo "[4] Установка плагинов ..."
    if confirm "Нужна регистрация игроков(openlogin)?"; then
        URL=$(curl -s "https://api.modrinth.com/v2/project/openlogin/version/1.6.7" | jq -r '.files[0].url') && wget "$URL" -O plugins/OpenLogin.jar
    fi

    echo "[5] Готово!"
    echo "Запуск сервера - команда run-mc"

else
    echo "Не удалось определить дистрибутив (файл /etc/os-release отсутствует)"
fi