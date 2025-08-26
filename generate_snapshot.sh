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

# --- FUNÇÃO USO ---
usage() {
    echo "Uso: $0 -d <dbname>"
    exit 1
}

# --- PARSING DE ARGUMENTOS ---
while getopts "d:" opt; do
  case $opt in
    d) DB_NAME="$OPTARG";;
    *) usage ;;
  esac
done

# --- VERIFICA OBRIGATÓRIO ---
if [[ -z "$DB_NAME" ]]; then
  usage
fi

# --- PREPARAR PASTA ---
DB_CHANGELOG_DIR="${CHANGELOG_DIR}/${DB_NAME}"
mkdir -p "$DB_CHANGELOG_DIR"

# --- GERAR TIMESTAMP PARA O NOME DO SNAPSHOT ---
TIMESTAMP=$(date +"%Y%m%d%H%M")

# --- CAMINHO DO SNAPSHOT ---
SNAPSHOT_FILE="${DB_CHANGELOG_DIR}/snapshot-${TIMESTAMP}.json"

# --- GERAR SNAPSHOT ---
echo "⚡ Gerando snapshot do banco ${DB_NAME} em ${SNAPSHOT_FILE}..."

docker compose exec liquibase liquibase \
  --url="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}" \
  --username="${DB_USER}" \
  --password="${DB_PASS}" \
  --snapshotFormat=json \
  snapshot > "$SNAPSHOT_FILE"

# --- FEEDBACK FINAL ---
if [ -s "$SNAPSHOT_FILE" ]; then
  echo "✅ Snapshot criado com sucesso: ${SNAPSHOT_FILE}"
else
  echo "❌ Erro: snapshot não foi criado."
  exit 1
fi