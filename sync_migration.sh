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
MIGRATION_FILE=""

# --- FUNÇÃO USO ---
usage() {
    echo "Uso: $0 -d <dbname> -f <migration_file>"
    echo "Exemplo: ./sync_migration.sh -d noharm -f V1_1_add_db_name.sql"
    exit 1
}

# --- PARSING DE ARGUMENTOS ---
while getopts "d:f:" opt; do
  case $opt in
    d) DB_NAME="$OPTARG";;
    f) MIGRATION_FILE="$OPTARG";;
    *) usage ;;
  esac
done

# --- VERIFICA OBRIGATÓRIOS ---
if [[ -z "$DB_NAME" || -z "$MIGRATION_FILE" ]]; then
  usage
fi

# --- VERIFICA SE O ARQUIVO EXISTE ---
DB_CHANGELOG_DIR="${CHANGELOG_DIR}/${DB_NAME}"
FULL_PATH="${DB_CHANGELOG_DIR}/${MIGRATION_FILE}"

if [ ! -f "$FULL_PATH" ]; then
  echo "❌ Migration file não encontrado: ${FULL_PATH}"
  exit 1
fi

# --- REGISTRAR MIGRATION (SYNC) ---
echo "⚡ Registrando (sync) migration ${MIGRATION_FILE} no banco ${DB_NAME}..."

docker compose exec liquibase liquibase \
  --url="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}" \
  --username="${DB_USER}" \
  --password="${DB_PASS}" \
  --changeLogFile="changelog/${DB_NAME}/${MIGRATION_FILE}" \
  changelogSync

# --- FEEDBACK FINAL ---
if [ $? -eq 0 ]; then
  echo "✅ Migration sincronizada com sucesso!"
else
  echo "❌ Erro ao sincronizar a migration."
  exit 1
fi