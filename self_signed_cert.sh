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

# Вывод сообщения с ASCII-артом
cat << "EOF"
============================================================
       Подпишись на нас на Youtube: anten-ka
============================================================
EOF

# Генерация QR-кода для чаевых
TIP_LINK="https://pay.cloudtips.ru/p/7410814f"
echo "Сканируй QR-код для чаевых:"
qrencode -t ANSIUTF8 "$TIP_LINK"
echo "============================================================"

# Параметры сертификата
CERT_DIR="/etc/ssl/self_signed_cert" # Директория для сохранения сертификата
CERT_NAME="self_signed" # Имя сертификата
DAYS_VALID=3650 # Срок действия сертификата (10 лет)

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
  echo "Самоподписной сертификат успешно создан."
  echo "Сертификат: $CERT_PATH"
  echo "Ключ: $KEY_PATH"
else
  echo "Ошибка при создании сертификата."
  exit 1
fi
