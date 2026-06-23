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

check_integrity() {
    EXPECTED_SHA256="7c50352ffb65074ffb6736279f0418c2132e49c7ea96fbcfbf9fdfa19ba04a91"
    if [ -f "$FILENAME" ]; then
        local current_sha256
        current_sha256=$(sha256sum "$FILENAME" | awk '{print $1}')
        
        if [ "$current_sha256" = "$EXPECTED_SHA256" ]; then
            return 0
        fi
    fi
    return 1
}

confirm() {
    if [ "$NOCONFIRM" = true ]; then
        return 0
    fi

    local prompt_text="${1:-Вы уверены?}"
    local default_input="${2:-y}"
    default_input="${default_input,,}"
    local prompt
    local default_action

    case "$default_input" in
        "0"|"n"|"no")
            prompt="$prompt_text [y/N]: "
            default_action="no"
            ;;
        *)
            prompt="$prompt_text [Y/n]: "
            default_action="yes"
            ;;
    esac

    local response
    while true; do
        read -r -p "$prompt" response
        response="${response,,}" 
        if [ -z "$response" ]; then
            response="$default_action"
        fi

        case "$response" in
            "y"|"yes")
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

RESET='\033[0m'
BG_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'

log_step() {
    echo -e "\n${BG_BLUE}$1${RESET}"
}

if [ -f /etc/os-release ]; then

    . /etc/os-release
    log_step "Обнаруженная ос: $NAME"
    
    log_step "[1] Установка зависимостей ..."
    case "$ID" in
        ubuntu|debian)
            if confirm "Обновить пакеты?"; then
                sudo apt update -y && sudo apt upgrade -y
            fi
            sudo apt install -y openjdk-21-jre-headless jq wget curl
            ;;
        centos|rhel|fedora)
            if confirm "Обновить пакеты?"; then
                sudo dnf update -y && dnf upgrade -y
            fi
            sudo dnf install -y openjdk-21-jre-headless jq wget curl
            ;;
        arch)
            if confirm "Обновить пакеты?"; then
                sudo pacman -Syu --noconfirm
            fi
            sudo pacman -S --noconfirm jre21-openjdk-headless jq wget curl
            ;;
        *)
            echo "Неподдерживаемая ОС"
            exit 1
            ;;
    esac

    if [ -d "$SAVEPATH" ] && [ "$(ls -A "$SAVEPATH" 2>/dev/null)" ]; then
        if check_integrity; then
            if confirm "Предупреждение: Сервер уже установлен. Вы уверены что хотите его удалить и установить заново?" "n"; then
                echo "Удаление сервера..."
                rm -rf "$SAVEPATH"
            else
                echo "Остановка скрипта по требованию пользователя."
                exit 0
            fi
        else
            echo "Предупреждение: Директория '$SAVEPATH' уже существует и содержит файлы, но возможно в ней повреждённый folia."
            if confirm "Удалить существующую папку и начать чистую установку?" "n"; then
                echo "Удаляем старую директорию..."
                rm -rf "$SAVEPATH"
            else
                echo "Остановка скрипта по требованию пользователя."
                exit 0
            fi
        fi
    fi

    mkdir -p $SAVEPATH
    cd $SAVEPATH || exit 1

    log_step "[2] Скачиваем folia 1.20.4 ..."
    wget "https://api.papermc.io/v2/projects/folia/versions/1.20.4/builds/26/downloads/folia-1.20.4-26.jar" -O $FILENAME

    log_step "[3] Первый запук ..."
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
    MOTD_TEXT="§6Folia §e1.20.4 §7on '§b${REAL_USER}§7'  §cby §a@§2g§ae§2o§am§2i§at§21"
    if [ -f server.properties ]; then
        if grep -q "^motd=" server.properties; then
            sed -i "s|^motd=.*|motd=${MOTD_TEXT}|" server.properties
        else
            echo "motd=${MOTD_TEXT}" >> server.properties
        fi
    else
        echo "motd=${MOTD_TEXT}" > server.properties
    fi

    log_step "[4] Установка плагинов ..."
    mkdir -p plugins
    if confirm "Нужна регистрация игроков(OpenLogin)?"; then
        echo "Скачиваем OpenLogin..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/openlogin/version/1.6.7" | jq -r '.files[0].url') && wget -q "$URL" -O plugins/OpenLogin.jar
        mkdir -p config
        mkdir -p plugins/OpeNLogin && echo "openlogin" > plugins/OpeNLogin/.setup
        (echo stop) | java -jar $FILENAME --nogui
        sed -i \
            -e 's/^allow-advertising:.*/allow-advertising: false/' \
            -e "s/^languageFile:.*/languageFile: 'messages_ru.yml'/" \
            plugins/OpeNLogin/config.yml
    fi
    if confirm "Нужна поддержка старых/новых клиентов (ViaVersion & ViaBackwards)?"; then
        echo "Скачиваем ViaVersion..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/viaversion/version" | jq -r '.[0].files[0].url')
        [ -n "$URL" ] && [ "$URL" != "null" ] && wget -q "$URL" -O plugins/ViaVersion.jar

        echo "Скачиваем ViaBackwards..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/viabackwards/version" | jq -r '.[0].files[0].url')
        [ -n "$URL" ] && [ "$URL" != "null" ] && wget -q "$URL" -O plugins/ViaBackwards.jar
    fi
    if confirm "Нужен WorldEdit (WorldEdit & WorldEditSelectionVisualizer)?"; then
        echo "Скачиваем WorldEdit..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/worldedit/version" | jq -r '.[0].files[0].url')
        [ -n "$URL" ] && [ "$URL" != "null" ] && wget -q "$URL" -O plugins/WorldEdit.jar

        echo "Скачиваем WESV(WorldEditSelectionVisualizer)..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/wesv/version" | jq -r '.[0].files[0].url')
        [ -n "$URL" ] && [ "$URL" != "null" ] && wget -q "$URL" -O plugins/WorldEditSelectionVisualizer.jar
        if confirm "Нужен приват (WorldGuard)?"; then
            echo "Скачиваем WorldGuard..."
            wget -q "https://cdn.modrinth.com/data/DKY9btbd/versions/pI4UHLJL/worldguard-bukkit-7.0.17.jar" -O plugins/WorldGuard.jar
        fi
    fi

    if confirm "Нужен античит (GrimAC)?"; then
        echo "Скачиваем Grim Anticheat..."
        URL=$(curl -s "https://api.modrinth.com/v2/project/grimac/version/wDqdP7DQ" | jq -r '.files[0].url')
        wget -q "$URL" -O plugins/GrimAC.jar
    fi

    log_step "[5] Настройка системы ..."
    wget https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/run.sh -O run.sh
    chmod +x run.sh
    BASHRC_FILE="$REAL_HOME/.bashrc"
    ALIAS_LINE="alias run-mc='$SAVEPATH/run.sh'"
    if ! grep -Fq "alias run-mc=" "$BASHRC_FILE"; then
        echo "" >> "$BASHRC_FILE"
        echo "$ALIAS_LINE" >> "$BASHRC_FILE"
    fi
    sudo chown -R "$REAL_USER":"$REAL_USER" "$SAVEPATH"


    log_step "[6] Готово!"
    log_step "Чтобы использовать команду 'run-mc', перезапустите терминал или выполните: source ~/.bashrc"
    log_step "Чтобы удалить пропишите: bash <(curl -fsSL https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/uninstall.sh)"
    log_step "Для запуска сервера пропишите 'run-mc'"

else
    echo "Не удалось определить дистрибутив (файл /etc/os-release отсутствует)"
fi
