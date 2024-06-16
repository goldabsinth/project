#!/bin/bash

# 1. Проверка на наличие репозитория Kali Linux в списке репозиториев
if grep -Fxq "deb http://http.kali.org/kali kali-rolling main" /etc/apt/sources.list
then
    echo "Kali Linux repository already exists"
else
    echo "Adding Kali Linux repository"
    echo "deb http://http.kali.org/kali kali-rolling main" | sudo tee -a /etc/apt/sources.list
fi

# 2. Обновление пакетного менеджера
echo "Updating package manager"
sudo apt-get update

# 3. Установка и запуск Apache2
echo "Installing and starting Apache2"
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2

# 4. Установка Python
echo "Installing Python"
sudo apt-get install -y python3 python3-pip

# 5. Установка и поднятие SSH-сервера
echo "Installing and starting SSH server"
sudo apt-get install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# 6. Сихронизация даты и времени
echo "Syncing date and time"
sudo timedatectl set-ntp true

# 7. Установка и настройка vsftpd
echo "Installing and configuring vsftpd"
sudo apt-get install -y vsftpd
sudo nano /etc/vsftpd.conf <<EOL
anonymous_enable = NO
local_enable = YES
write_enable = YES
local_umask = 022
xferlog_enable = YES
xferlog_std_format=YES
connect_from_port_20 = YES
chroot_local_user = YES
allow_writeable_chroot = YES
ssl_enable=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
rsa_cert_file=/etc/ssl/private/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_ciphers=HIGH
use_localtime=YES
EOL
sudo systemctl enable vsftpd
sudo systemctl restart vsftpd

# 8. Установка и настройка xrdp
echo "Installing and configuring xrdp"
sudo apt install -y xrdp
sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
sudo cat > /etc/xrdp/xrdp.ini <<EOL
[Globals]
ini_version=1
fork=true
port=3389

[Xorg]
name=Xorg
lib=libxup.so
username=ask
password=ask
ip=127.0.0.1
port=-1
code=20

[Logging]
log_level=INFO
log_file=/var/log/xrdp.log
EOL

sudo systemctl enable xrdp
sudo systemctl restart xrdp

# Установка графического окружения xfce4
echo "Installing xfce4"
sudo apt-get install -y xfce4

#  Настройка графического окружения xfce4 для RDP-сессии
echo "Configuring xfce4 for RDP session"
echo xfce4-session > ~/.xsession

# 9. Установка git
echo "Installing git"
sudo apt-get install -y git

# 10. Создание пользователей user1 и user2 в группе user1
echo "Создание пользователей и добавление их в группу"
sudo addgroup user1
sudo adduser user1 --ingroup user1
sudo adduser user2 --ingroup user1

# 11. Сбор информации о системе и запись в файл testsysteminfo в директории /home/user
echo "Сбор информации о системе"

# Сбор информации о системе
sudo lsb_release -a > system_info.txt
sudo uname -a >> system_info.txt
sudo df -h >> system_info.txt
sudo free -m >> system_info.txt

# Перемещение файла в нужную директорию
sudo mv system_info.txt /home/user/testsysteminfo

# 12. Вывод погоды на завтра каждый день в 21:00
echo "Configuring weather script"

# Проверка существования файла /etc/cron.d/weather
if [ ! -f /etc/cron.d/weather ]
then
    echo "Weather cron job file not found, creating it..."
    sudo nano /etc/cron.d/weather
fi

# Добавление строки в файл /etc/cron.d/weather
sudo sed -i -e '$ i\
0 21 * * * root curl -s '\''https://api.openweathermap.org/data/2.5/forecast?q=Moscow&lang=ru&units=metric&appid=45aa4bec2f42b1a6cda66689690685b5'\'' | jq -r ''.list[1].weather[0].description, .list[1].main.temp_max, .list[1].main.temp_min'' | fold -w1 -s >> /var/log/weather.log
' /etc/cron.d/weather

echo "Настройка скрипта завершена"
