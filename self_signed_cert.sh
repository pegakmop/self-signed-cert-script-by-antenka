#!/bin/bash

# Скрипт для создания самоподписного сертификата на 10 лет

# Убедись, что OpenSSL установлен
if ! command -v openssl &> /dev/null; then
  echo "OpenSSL не установлен. Устанавливаю OpenSSL..."
  sudo apt update && sudo apt install -y openssl
  if [ $? -ne 0 ]; then
    echo "Не удалось установить OpenSSL. Завершаю скрипт."
    exit 1
  fi
fi

# Убедись, что qrencode установлен
if ! command -v qrencode &> /dev/null; then
  echo "qrencode не установлен. Устанавливаю qrencode..."
  sudo apt update && sudo apt install -y qrencode
  if [ $? -ne 0 ]; then
    echo "Не удалось установить qrencode. Завершаю скрипт."
    exit 1
  fi
fi

# Проверка и установка 3x-ui
if ! command -v 3x-ui &> /dev/null; then
  echo "3X-UI не установлен. Устанавливаю 3X-UI..."
  bash <(curl -Ls https://raw.githubusercontent.com/3x-ui/3x-ui/master/install.sh)
  if [ $? -ne 0 ]; then
    echo "Не удалось установить 3X-UI. Завершаю скрипт."
    exit 1
  fi
else
  echo "3X-UI уже установлен."
fi

# Запуск и включение автозагрузки для 3X-UI
systemctl enable 3x-ui
systemctl start 3x-ui

# Функция обратного отсчёта
countdown() {
  for i in {10..1}; do
    echo -ne "ОЖИДАНИЕ $i СЕКУНД...\r"
    sleep 1
  done
  echo -e "ОЖИДАНИЕ ЗАВЕРШЕНО!\n"
}

# Вывод сообщения с ASCII-артом
cat << "EOF"
============================================================
       ПОДПИШИСЬ НА НАС НА YOUTUBE: ANTEN-KA
============================================================
EOF

# Генерация QR-кода для чаевых
echo "############################################################"
echo "#                    QR-КОД ДЛЯ ЧАЕВЫХ                     #"
echo "############################################################"
TIP_LINK="https://pay.cloudtips.ru/p/7410814f"
qrencode -t ANSIUTF8 "$TIP_LINK"
countdown

# Разделитель из 10 строк
for i in {1..10}; do echo "============================================================"; done

# QR-код YouTube
echo "############################################################"
echo "#                      QR-КОД YOUTUBE                      #"
echo "############################################################"
YT_LINK="https://www.youtube.com/antenkaru"
qrencode -t ANSIUTF8 "$YT_LINK"
countdown

# Разделитель из 10 строк
for i in {1..10}; do echo "============================================================"; done

# QR-код Boosty
echo "############################################################"
echo "#                      QR-КОД BOOSTY                       #"
echo "############################################################"
BOOSTY_LINK="https://boosty.to/anten-ka"
qrencode -t ANSIUTF8 "$BOOSTY_LINK"
countdown

# Разделитель из 10 строк
for i in {1..10}; do echo "============================================================"; done

echo "============================================================"

# Параметры сертификата
CERT_DIR="/etc/ssl/self_signed_cert" # Директория для сохранения сертификата
CERT_NAME="self_signed"              # Имя сертификата
DAYS_VALID=3650                      # Срок действия сертификата (10 лет)

# Создаем директорию для сертификата, если ее нет
mkdir -p "$CERT_DIR"

# Путь к файлам
CERT_PATH="$CERT_DIR/$CERT_NAME.crt"
KEY_PATH="$CERT_DIR/$CERT_NAME.key"

# Генерация приватного ключа и сертификата
openssl req -x509 -nodes -days $DAYS_VALID -newkey rsa:2048 \
  -keyout "$KEY_PATH" \
  -out "$CERT_PATH" \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=example.com"

if [ $? -eq 0 ]; then
  echo "САМОПОДПИСНОЙ СЕРТИФИКАТ УСПЕШНО СОЗДАН."
  echo "ТРЕБУЕТСЯ В ПАНЕЛИ 3X-UI В БЕЗОПАСНОСТИ ПРОПИСАТЬ ДАННЫЕ ПУТИ:"
  echo "SSL CERTIFICATE PATH: $CERT_PATH"
  echo "SSL KEY PATH: $KEY_PATH"
  echo "СЕРТИФИКАТ: $CERT_PATH"
  echo "КЛЮЧ: $KEY_PATH"
else
  echo "ОШИБКА ПРИ СОЗДАНИИ СЕРТИФИКАТА."
  exit 1
fi

