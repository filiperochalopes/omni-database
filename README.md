## Criando senhas

```bash
python3 -c "import secrets, string; print(''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(12)))"
```

## Criando a secret key para criptografia de senhas dentro do banco

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

## Executando liquibase

### Rodandouma migration manualmente

```bash
./generate_migration.sh -d meubanco -m "nova tabela usuarios"
```

```bash
docker-compose exec liquibase liquibase \
  --url=jdbc:mysql://db:3306/meubanco \
  --username=root \
  --password=senha \
  --changeLogFile=changelog/changelog.sql \
  update
```

Exemplo:

```bash
export $(grep -v '^#' .env | xargs)
docker compose exec liquibase liquibase \
  --url=jdbc:mysql://db-omni:3306/noharm \
  --username=root \
  --password=${DB_ROOT_PASS} \
  --changeLogFile=changelog/noharm/V1_create_database_and_initial_tables.sql \
  update
```

### Gerar uma migration automática

```bash
docker-compose exec liquibase liquibase \
  --url=jdbc:mysql://db:3306/meubanco \
  --username=root \
  --password=senha \
  --changeLogFile=changelog/diff.sql \
  diffChangeLog
```