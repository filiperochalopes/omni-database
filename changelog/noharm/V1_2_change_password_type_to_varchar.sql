-- liquibase formatted sql

-- changeset filipelopes:006 comment:Altera coluna password para VARCHAR em db_connections
ALTER TABLE db_connections
MODIFY COLUMN password VARCHAR(255) NULL DEFAULT NULL;