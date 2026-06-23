#!/bin/bash

sudo -v || exit 1
set -e

NOCONFIRM=false
if [[ "$1" == "--noconfirm" ]]; then
    NOCONFIRM=true
fi

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
FILENAME="folia-1.20.4.jar"
SERVER_DIR="$REAL_HOME/.papermc-geomit"
WORLD_NAME="world"
MINECRAFT_VERSION="1.20.4"

PACKS_SLUGS=("terralith" "tectonic" "geophilic" "incendium" "explorify")
PACKS_NAMES=("Terralith (Глобальный оверхолд)" "Tectonic (Масштабные горы и реки)" "Geophilic (Улучшение ванильных биомов)" "Incendium (Полный реформат Незера)" "Explorify (Новые крутые данжи)")
PACKS_CHOICE=(0 0 0 0 0)

NUM_PACKS=${#PACKS_SLUGS[@]}
CURSOR=0

draw_menu() {
    clear
    echo -e "\e[1;36m=== НАСТРОЙКА ГЕНЕРАЦИИ МИРА FOLIA $MINECRAFT_VERSION ===\e[0m"
    echo -e "Используйте \e[1;33m↑/↓\e[0m для перемещения, \e[1;33m[Пробел]\e[0m для выбора, \e[1;32m[Enter]\e[0m для старта.\n"
    
    for ((i=0; i<NUM_PACKS; i++)); do
        if [ "${PACKS_CHOICE[$i]}" -eq 1 ]; then
            BOX="[\e[1;32mX\e[0m]"
        else
            BOX="[ ]"
        fi
        if [ $i -eq $CURSOR ]; then
            echo -e " \e[1;33m➔\e[0m $BOX ${PACKS_NAMES[$i]}"
        else
            echo -e "   $BOX ${PACKS_NAMES[$i]}"
        fi
    done
    echo -e "\n--------------------------------------------------"
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

stty -echo
trap 'stty echo; exit' INT TERM

while true; do
    draw_menu
    
    read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        if [[ $key == "[A" ]]; then
            ((CURSOR--))
            [ $CURSOR -lt 0 ] && CURSOR=$((NUM_PACKS - 1))
        elif [[ $key == "[B" ]]; then
            ((CURSOR++))
            [ $CURSOR -ge $NUM_PACKS ] && CURSOR=0
        fi
    elif [[ $key == "" ]]; then
        break
    elif [[ $key == " " ]]; then
        if [ "${PACKS_CHOICE[$CURSOR]}" -eq 1 ]; then
            PACKS_CHOICE[$CURSOR]=0
        else
            PACKS_CHOICE[$CURSOR]=1
        fi
    fi
done

stty echo

clear
echo -e "\e[1;31m=== НАЧИНАЕТСЯ ПЕРЕСОЗДАНИЕ МИРА ===\e[0m"

cd "$SERVER_DIR" || { echo "Ошибка: Папка сервера не найдена!"; exit 1; }

if confirm "Вы уверены что хотите провести вайп(полное удаление мира)?" "n"; then 
  echo "Удаление старых папок мира..."
  rm -rf "${WORLD_NAME}" "${WORLD_NAME}_nether" "${WORLD_NAME}_the_end"
else
  echo "Остановка скрипта по требованию пользователя."
  exit 0
fi

DATAPACK_DIR="${WORLD_NAME}/datapacks"
mkdir -p "$DATAPACK_DIR"

for ((i=0; i<NUM_PACKS; i++)); do
    if [ "${PACKS_CHOICE[$i]}" -eq 1 ]; then
        SLUG="${PACKS_SLUGS[$i]}"
        echo -e "\nПоиск датапака \e[1;32m$SLUG\e[0m для 1.20.4..."
        
        URL=$(curl -s "https://api.modrinth.com/v2/project/${SLUG}/version?game_versions=%5B%22${MINECRAFT_VERSION}%22%5D&loaders=%5B%22datapack%22%5D" \
              | jq -r '.[0].files[] | select(.filename | endswith(".zip")) | .url' | head -n 1)
        
        if [ -z "$URL" ] || [ "$URL" == "null" ]; then
            URL=$(curl -s "https://api.modrinth.com/v2/project/${SLUG}/version?game_versions=%5B%22${MINECRAFT_VERSION}%22%5D" \
                  | jq -r '.[0].files[] | select(.filename | endswith(".zip")) | .url' | head -n 1)
        fi

        if [ ! -z "$URL" ] && [ "$URL" != "null" ]; then
            echo "Скачивание: $URL"
            wget -q "$URL" -O "$DATAPACK_DIR/${SLUG}.zip"
            echo "Успешно установлен: $SLUG"
        else
            echo -e "\e[1;31mОшибка:\e[0m Не удалось найти .zip файл для $SLUG под 1.20.4 на Modrinth."
        fi
    fi
done

echo -e "\n\e[1;32m=== Готово! Папка $WORLD_NAME подготовлена. Запускайте Folia: run-mc ===\e[0m"
