# papermc (folia 1.20.4)

## Installation
Этот скрипт помогает автоматически установить `java` и `folia-1.20.4`, а также установить базовые плагины и настроить доступ для игроков без лицензии.

**Установка (с интерактивными вопросами):**
```bash
bash <(curl -sSL https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/bootstrap.sh)
```
**Полная установка (без вопросов):**
```bash
curl -sSL https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/bootstrap.sh | sudo bash -s -- --noconfirm
```

при скорости интернета `12 Мбит/с` полная установка занимает от `40.5 секунд` до `1 минуты 26 секунд`

## Running the Server
Чтобы запустить сервер просто пропишите одну команду в терминале:
```bash
run-mc
```

## Uninstallation
Чтобы полностью удалить сервер, миры, плагины, настройки и команду `run-mc`, выполните:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/uninstall.sh)
```
Скрипт запросит подтверждение удалением через ввод `YES`.

## Overview
> **Supported Package Managers:** `apt` (Debian/Ubuntu), `dnf` (RHEL/CentOS/Fedora), and `pacman` (Arch Linux).
### About folia
Тут используется **Folia 1.20.4** (`folia-1.20.4-26.jar`) — это оптимизированный сервер Minecraft на базе `PaperMC`. Он работает быстрее и даёт меньше просадок TPS, если вы запускаете его на слабом компьютере. Важно учесть, что не все плагины Paper на нём работают.

### About questions
При установке задаются (если вы, конечно, не поставили флаг `--noconfirm`) следующие вопросы:
1. `Обновить ли пакеты` — перед установкой Java (`openjdk-21-jre-headless`). Рекомендуется, чтобы базы пакетов были обновлены для корректной установки Java с помощью вашего пакетного менеджера.
2. `Включить поддержку игроков без лицензии (offline-mode)` — если её не включить, **при входе с лаунчера без лицензии\*** будет написано "**перезапустите лаунчер или игру**" и вы не сможете подключиться к серверу.
3. `Нужна регистрация игроков (OpenLogin)?` — установка плагина, добавляющего команды `/reg` (`/register`) и `/login`. При **выключенной проверке лицензии\*** этот плагин нужен, чтобы никто не мог зайти под чужим ником и мешать игре.
4. `Нужна поддержка старых/новых клиентов (ViaVersion & ViaBackwards)?` — не установив эти 2 плагина, вам потребуется, чтобы у всех игроков стояла версия игры **1.20.4**.
5. `Нужен WorldEdit (WorldEdit & WorldEditSelectionVisualizer)?` - плагин для редактирования мира с помощью деревянного топора (`//wand`).
6. `Нужен приват (WorldGuard)?` - плагин, дающий возможность приватить регионы. Требует наличие `WorldEdit`.
7. `Нужен античит (GrimAC)?` — установка плагина античита. Отлично блокирует работу базовых читов.

*\*Я не поддерживаю использование пиратского ПО, а лишь предполагаю возможность такого выбора со стороны пользователя. Ответственность за использование нелицензионного контента полностью лежит на вас.*

---

### Disclaimer and Terms of Use

This script is an independent automation tool provided "as is" without any warranties, express or implied. By executing this script, you agree to the following terms:

* **Mojang EULA Compliance:** This script automatically sets `eula=true` solely for deployment convenience. By running this script, **you** (the user) acknowledge and agree to comply with the official Minecraft End User License Agreement (EULA). The author of this script does not act as your agent and bears no responsibility for your acceptance of these terms.
* **Offline Mode (`online-mode=false`):** Disabling official Mojang authentication is a native feature of PaperMC designed for local area networks (LAN), testing, or offline proxy networks (e.g., Velocity, BungeeCord). The author does not condone, encourage, or facilitate software piracy. Any use of this configuration to bypass legitimate software ownership is entirely at the user's own risk.
* **Third-Party Content (Modrinth API):** This script interacts with the Modrinth API to automatically download third-party plugins. The author does not host, review, or control these plugins. You acknowledge that:
    * The author is not responsible for the content, safety, malicious code, or stability of any downloaded third-party software.
    * You are bound by Modrinth's Terms of Service and the individual licenses of the downloaded plugins.
* **Intellectual Property:** "Minecraft", "PaperMC", and "Modrinth" are trademarks of their respective owners. This script is not affiliated with, endorsed by, or associated with Mojang Studios, Microsoft, the PaperMC team, or Rinth Inc.
* **Limitation of Liability:** In no event shall the author be liable for any claims, damages, server bans, data loss, security breaches, or other liabilities arising from the use, misuse, or inability to use this script.
