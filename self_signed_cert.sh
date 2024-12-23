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
       ПОДПИШИСЬ НА НАС НА YOUTUBE: ANTEN-KA
============================================================
EOF

# Генерация QR-кода для чаевых
echo "############################################################"
echo "#                    QR-КОД ДЛЯ ЧАЕВЫХ                     #"
echo "############################################################"
TIP_LINK="https://pay.cloudtips.ru/p/7410814f"
qrencode -t ANSIUTF8 "$TIP_LINK"

# Разделитель (20 пустых строк)
for i in {1..20}; do echo ""; done

# Разделитель
echo "############################################################"
echo "#                      QR-КОД YOUTUBE                      #"
echo "############################################################"
YT_LINK="https://www.youtube.com/antenkaru"
qrencode -t ANSIUTF8 "$YT_LINK"

# Разделитель (20 пустых строк)
for i in {1..20}; do echo ""; done

echo "############################################################"
echo "#                      QR-КОД BOOSTY                       #"
echo "############################################################"
BOOSTY_LINK="https://boosty.to/anten-ka"
qrencode -t ANSIUTF8 "$BOOSTY_LINK"

# Разделитель (20 пустых строк)
for i in {1..20}; do echo ""; done

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

