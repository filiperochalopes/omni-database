#!/bin/bash

# --- CARREGAR VARIÁVEIS DO .env SE EXISTIR ---
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# --- CONFIGURAÇÕES PADRÃO (podem ser sobrescritas pelo .env) ---
CHANGELOG_DIR="./changelog"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-senha}"
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-3306}"

# --- ARGUMENTOS ---
DB_NAME=""
VERSION=""
MESSAGE=""

# --- FUNÇÃO USO ---
usage() {
    echo "Uso: $0 -d <dbname> -m \"mensagem da migration\" [-v <versão>]"
    exit 1
}

# --- PARSING DE ARGUMENTOS ---
while getopts "d:m:v:" opt; do
  case $opt in
    d) DB_NAME="$OPTARG";;
    m) MESSAGE="$OPTARG";;
    v) VERSION="$OPTARG";;
    *) usage ;;
  esac
done

# --- VERIFICA OBRIGATÓRIOS ---
if [[ -z "$DB_NAME" || -z "$MESSAGE" ]]; then
  usage
fi

# --- PREPARAR PASTA ---
DB_CHANGELOG_DIR="${CHANGELOG_DIR}/${DB_NAME}"
mkdir -p "$DB_CHANGELOG_DIR"

# --- FORMATAR MENSAGEM ---
FORMATTED_MESSAGE=$(echo "$MESSAGE" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

# --- IDENTIFICAR VERSÃO ---
if [ -z "$VERSION" ]; then
  LAST_VERSION=$(ls "$DB_CHANGELOG_DIR" 2>/dev/null | grep -oP '^V[0-9_]+(?=_).*\.sql' | sort -V | tail -n 1 | sed 's/^V//;s/_.*//')
  if [ -z "$LAST_VERSION" ]; then
    VERSION="1"
  else
    VERSION=$((LAST_VERSION + 1))
  fi
fi

# Substituir ponto por underline se existir (ex: 2.1 vira 2_1)
FORMATTED_VERSION=$(echo "$VERSION" | tr '.' '_')

# --- NOME DO ARQUIVO FINAL ---
OUTPUT_FILE="${DB_CHANGELOG_DIR}/V${FORMATTED_VERSION}_${FORMATTED_MESSAGE}.sql"

# --- EXECUTAR LIQUIBASE ---
docker compose exec liquibase liquibase \
  --url="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}" \
  --username="${DB_USER}" \
  --password="${DB_PASS}" \
  --changeLogFile="/liquibase/changelog/${DB_NAME}/$(basename "$OUTPUT_FILE")" \
  diffChangeLog

# --- FEEDBACK ---
echo "✅ Migration gerada: ${OUTPUT_FILE}"