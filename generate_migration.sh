#!/bin/bash

# --- CARREGAR VARIÁVEIS DO .env SE EXISTIR ---
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# --- CONFIGURAÇÕES PADRÃO (podem ser sobrescritas pelo .env) ---
CHANGELOG_DIR="./changelog"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-senha}"
DB_HOST="${DB_HOST:-db-omni}"
DB_PORT="3306"

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
OUTPUT_FILE="${DB_CHANGELOG_DIR}/V${FORMATTED_VERSION}_${FORMATTED_MESSAGE}.mysql.sql"

# --- ENCONTRAR O ÚLTIMO SNAPSHOT ---
SNAPSHOT_FILE=$(ls -t "$DB_CHANGELOG_DIR"/snapshot-*.json 2>/dev/null | head -n 1)

if [ -z "$SNAPSHOT_FILE" ]; then
  echo "❌ Nenhum snapshot encontrado para ${DB_NAME} em ${DB_CHANGELOG_DIR}"
  echo "⚡ Gere um snapshot primeiro usando ./generate_snapshot.sh -d ${DB_NAME}"
  exit 1
fi

echo "⚡ Usando snapshot: ${SNAPSHOT_FILE}"

# --- EXECUTAR LIQUIBASE COM DIFF ENTRE SNAPSHOT E BANCO ATUAL ---
docker compose exec liquibase liquibase \
  --referenceUrl="offline:json?file=/liquibase/changelog/${DB_NAME}/$(basename "$SNAPSHOT_FILE")" \
  --url="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}" \
  --username="${DB_USER}" \
  --password="${DB_PASS}" \
  --changeLogFile="/liquibase/changelog/${DB_NAME}/$(basename "$OUTPUT_FILE")" \
  diffChangeLog

# --- VERIFICAR SE O ARQUIVO FOI CRIADO ---
if [ -s "$OUTPUT_FILE" ]; then
  echo "✅ Migration gerada com sucesso: ${OUTPUT_FILE}"
else
  echo "❌ Erro: o arquivo de migration não foi criado."
  exit 1
fi