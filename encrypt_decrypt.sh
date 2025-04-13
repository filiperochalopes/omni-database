#!/bin/bash

# Nome: encrypt_decrypt.sh
# Uso: ./encrypt_decrypt.sh "minhaSenhaSuperSecreta"

# --- CARREGAR .env ---
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# --- VERIFICA SECRET_KEY ---
if [ -z "$SECRET_KEY" ]; then
  echo "❌ SECRET_KEY não encontrada no .env."
  exit 1
fi

# --- VERIFICA ARGUMENTOS ---
if [ -z "$1" ]; then
  echo "❌ Informe a senha a ser criptografada como argumento."
  echo "Uso: $0 \"senha_a_criptografar\""
  exit 1
fi

# --- VARIÁVEIS ---
PASSWORD="$1"

# --- CRIPTOGRAFAR ---
CIPHER=$(echo -n "$PASSWORD" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$SECRET_KEY")
echo "🔒 Criptografado: $CIPHER"

# --- DESCRIPTOGRAFAR ---
DECRYPTED=$(echo "$CIPHER" | openssl enc -aes-256-cbc -a -d -salt -pbkdf2 -pass pass:"$SECRET_KEY")
echo "🔓 Descriptografado: $DECRYPTED"