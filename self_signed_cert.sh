#!/bin/bash

# Устанавливаем 3x-ui панель для VLESS и сертификаты на 10 лет

# Установка OpenSSL
if ! command -v openssl &> /dev/null; then
  sudo apt update && sudo apt install -y openssl
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# Установка qrencode
if ! command -v qrencode &> /dev/null; then
  sudo apt update && sudo apt install -y qrencode
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# Установка 3X-UI
if ! command -v x-ui &> /dev/null; then
  bash <(curl -Ls https://raw.githubusercontent.com/MHSanaei/3x-ui/master/install.sh)
  if [ $? -ne 0 ]; then
    exit 1
  fi
else
  echo "3X-UI уже установлен."
fi

# Запуск 3X-UI
systemctl daemon-reload
if systemctl list-units --full -all | grep -Fq 'x-ui.service'; then
  systemctl enable x-ui
  systemctl start x-ui
else
  x-ui
fi

# Функция ожидания нажатия Enter
wait_for_enter() {
  echo -e "Нажмите Enter, чтобы продолжить..."
  read -r
}

# ASCII-арт
cat << "EOF"
============================================================
       ПОДПИШИСЬ НА НАС НА YOUTUBE: ANTEN-KA
============================================================
EOF

# QR-код для чаевых
echo "############################################################"
echo "#                    QR-КОД ДЛЯ ЧАЕВЫХ                     #"
echo "############################################################"
TIP_LINK="https://pay.cloudtips.ru/p/7410814f"
qrencode -t ANSIUTF8 "$TIP_LINK"
wait_for_enter

# Разделитель из 3 строк
for i in {1..3}; do echo "============================================================"; done

# QR-код YouTube
echo "############################################################"
echo "#                      QR-КОД YOUTUBE                      #"
echo "############################################################"
YT_LINK="https://www.youtube.com/antenkaru"
qrencode -t ANSIUTF8 "$YT_LINK"
wait_for_enter

# Разделитель из 3 строк
for i in {1..3}; do echo "============================================================"; done

# QR-код Boosty
echo "############################################################"
echo "#                      QR-КОД BOOSTY                       #"
echo "############################################################"
BOOSTY_LINK="https://boosty.to/anten-ka"
qrencode -t ANSIUTF8 "$BOOSTY_LINK"
wait_for_enter

# Разделитель из 3 строк
for i in {1..3}; do echo "============================================================"; done

# Генерация сертификата
CERT_DIR="/etc/ssl/self_signed_cert"
CERT_NAME="self_signed"
DAYS_VALID=3650
mkdir -p "$CERT_DIR"
CERT_PATH="$CERT_DIR/$CERT_NAME.crt"
KEY_PATH="$CERT_DIR/$CERT_NAME.key"

openssl req -x509 -nodes -days $DAYS_VALID -newkey rsa:2048 \
  -keyout "$KEY_PATH" \
  -out "$CERT_PATH" \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=example.com"

if [ $? -eq 0 ]; then
  echo "SSL CERTIFICATE PATH: $CERT_PATH"
  echo "SSL KEY PATH: $KEY_PATH"
else
  exit 1
fi
