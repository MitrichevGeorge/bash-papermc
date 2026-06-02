# papermc (folia 1.20.4)

## Installation
Этот скрипт помогает установить `java` и `folia-1.20.4`, а затем установить плагины и настроить доступ без лицензии

**Установка(с вопросами):**
```
bash <(curl -sSL https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/bootstrap.sh)
```
**Полная установка (без вопросов):**
```
curl -sSL https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/bootstrap.sh | sudo bash -s -- --noconfirm
```

при скорости интернета `12 Мбит/с` полная установка занимает от `40.5 секунд` до `1 минуты 26 секунд`

## Run
Чтобы запустить просто пропишите одну команду:
```
run-mc
```


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