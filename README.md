# Omni Database

Omni Database é um projeto de banco de dados **relacional e genérico**, versionado com **Liquibase**, pensado para substituir planilhas e facilitar integrações diretas com ferramentas como **Appsmith**, **n8n** e outras plataformas low-code/no-code.

Esta aplicação fornece uma estrutura robusta para armazenamento de dados organizados, versionados e de fácil manutenção, ideal para automações e integrações dinâmicas.

---

## Visão Geral

- Banco de dados MariaDB versionado com **Liquibase**.
- Controle de versionamento através de **changesets**.
- Scripts auxiliares para **geração de senhas**, **secret keys** e **migrations**.
- Pensado para ser **extensível** e fácil de integrar.
- Substitui planilhas desestruturadas por dados relacionais consistentes.

---

## Pré-requisitos

Antes de executar o Liquibase, é necessário baixar o driver JDBC do MySQL:

```bash
wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar
```

Em seguida, adicione o driver ao seu `docker-compose.yml` no serviço `liquibase`:

```yaml
services:
  liquibase:
    image: liquibase/liquibase
    volumes:
      - ./changelog:/liquibase/changelog
      - ./mysql-connector-j-8.3.0.jar:/liquibase/lib/mysql-connector-j-8.3.0.jar
    command: tail -f /dev/null
    networks:
      - omni
```

Isso garante que o Liquibase consiga se conectar ao banco MariaDB.

---

## Criação de Senhas Aleatórias

Gere uma senha segura de 12 caracteres para uso geral:

```bash
python3 -c "import secrets, string; print(''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(12)))"
```

---

## Criação da Secret Key

Gere uma secret key segura para criptografia de senhas armazenadas no banco:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Essa chave será utilizada para **criptografar** e **descriptografar** senhas no banco.

---

## Executando Liquibase

O Liquibase é responsável por versionar o banco e aplicar as alterações de forma controlada.

### Rodar uma Migration Manualmente

1. Gerar uma migration com comentário:

```bash
./generate_migration.sh -d meubanco -m "nova tabela usuarios"
```

2. Aplicar as mudanças manualmente:

```bash
docker-compose exec liquibase liquibase \
  --url=jdbc:mysql://db:3306/meubanco \
  --username=root \
  --password=senha \
  --changeLogFile=changelog/changelog.sql \
  update
```

### Exemplo Real de Uso

1. Carregar variáveis do `.env`:

```bash
export $(grep -v '^#' .env | xargs)
```

2. Rodar a migration no banco `noharm`:

```bash
docker compose exec liquibase liquibase \
  --url=jdbc:mysql://db-omni:3306/noharm \
  --username=root \
  --password=${DB_ROOT_PASS} \
  --changeLogFile=changelog/noharm/V1_create_database_and_initial_tables.sql \
  update
```

---

## Gerar uma Migration Automática (diff)

Para comparar o estado atual do banco de dados e gerar automaticamente um arquivo de migration:

```bash
docker-compose exec liquibase liquibase \
  --url=jdbc:mysql://db:3306/meubanco \
  --username=root \
  --password=senha \
  --changeLogFile=changelog/diff.sql \
  diffChangeLog
```

Isso é útil para detectar mudanças no banco feitas fora do controle de versionamento e criar migrations rapidamente.

---

## Estrutura de Changesets

Cada migration é composta por **changesets** individuais.  
Cada `changeset` representa **uma alteração única e rastreável** no banco de dados.

Exemplo de changeset no formato SQL:

```sql
-- liquibase formatted sql

-- changeset filipelopes:001 comment:Criação da tabela de contatos
CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255)
);

-- changeset filipelopes:002 comment:Criação da tabela de conexões
CREATE TABLE db_connections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    host VARCHAR(255),
    port VARCHAR(10),
    username VARCHAR(255),
    password VARBINARY(255)
);
```

- **Autor:** Identifica quem criou a alteração (`filipelopes`).
- **ID:** Número único do changeset (`001`, `002`, etc).
- **Comment:** Comentário descritivo que é registrado no banco.

---

## Notas Finais

- Evite criar tabelas manualmente fora do Liquibase para manter o controle de versionamento.
- Use sempre `changesets` para novas tabelas, colunas, índices e dados iniciais.
- Em caso de criação manual de objetos, utilize o comando `changelogSync` para sincronizar o estado do banco:

```bash
docker compose exec liquibase liquibase \
  --url=jdbc:mysql://db-omni:3306/noharm \
  --username=root \
  --password=${DB_ROOT_PASS} \
  --changeLogFile=changelog/noharm/V1_create_database_and_initial_tables.sql \
  changelogSync
```

---

**Feito com ❤️ para integrações simples, escaláveis e sem bagunça.**