#!/bin/bash

sudo -v || exit 1
set -e

NOCONFIRM=false
if [[ "$1" == "--noconfirm" ]]; then
    NOCONFIRM=true
fi

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
SAVEPATH="$REAL_HOME/.papermc-geomit"
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
                # sudo apt upgarde -y
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

    mkdir -p $SAVEPATH
    cd $SAVEPATH

    echo "[2] Скачиваем folia 1.20.4 ..."
    wget "https://api.papermc.io/v2/projects/folia/versions/1.20.4/builds/26/downloads/folia-1.20.4-26.jar" -O $FILENAME

    echo "[3] Первый запук ..."
    java -jar $FILENAME nogui 
    echo "eula=true" > eula.txt
    if confirm "Включить поддержку игроков без лицензии (offline-mode)?"; then
        echo "Настраиваем сервер для работы без лицензии..."
        if [ -f server.properties ]; then
            sed -i 's/online-mode=true/online-mode=false/g' server.properties
        else
            echo "online-mode=false" > server.properties
        fi
    fi

    echo "[4] Установка плагинов ..."
    if confirm "Нужна регистрация игроков(openlogin)?"; then
        # URL=$(curl -s "https://api.modrinth.com/v2/project/openlogin/version/1.6.7" | jq -r '.files[0].url') && wget "$URL" -O plugins/OpenLogin.jar
        # mkdir -p config
        # (echo stop) | java -jar $FILENAME --nogui
        # sed -i \
        #     -e 's/^allow-advertising:.*/allow-advertising: false/' \
        #     -e "s/^languageFile:.*/languageFile: 'messages_ru.yml'/" \
        #     plugins/OpeNLogin/config.yml
        wget "https://repo.nickuc.com/files/latest/nLogin.jar" -O plugins/nLogin.jar
    fi
    if confirm "Нужна поддержка более новых и более старых клиентов (ViaVersion и ViaBackwards)?"; then
        echo "Скачиваем ViaVersion..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/viaversion/version" | jq -r '.[0].files[0].url')
        if [ -n "$URL" ] && [ "$URL" != "null" ]; then
            wget "$URL" -O plugins/ViaVersion.jar
        else
            echo "Ошибка: Не удалось получить ссылку для ViaVersion"
        fi

        echo "Скачиваем ViaBackwards..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/viabackwards/version" | jq -r '.[0].files[0].url')
        if [ -n "$URL" ] && [ "$URL" != "null" ]; then
            wget "$URL" -O plugins/ViaBackwards.jar
        else
            echo "Ошибка: Не удалось получить ссылку для ViaBackwards"
        fi
    fi
    # https://modrinth.com/plugin/grimac/version/wDqdP7DQ
    # https://modrinth.com/plugin/foxaddition/version/1.2.2
    if confirm "Нужен античит(FoxAddition)?"; then
        URL=$(curl -s "https://api.modrinth.com/v2/project/foxaddition/version/1.2.2" | jq -r '.files[0].url') && wget "$URL" -O plugins/FoxAddition.jar
    fi

    echo "Настройка прав доступа для пользователя $REAL_USER..."
    sudo chown -R "$REAL_USER":"$REAL_USER" "$SAVEPATH"

    echo "[5] Готово!"
    echo "Запуск сервера - команда run-mc"

else
    echo "Не удалось определить дистрибутив (файл /etc/os-release отсутствует)"
fi