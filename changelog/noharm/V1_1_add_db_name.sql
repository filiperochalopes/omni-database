-- liquibase formatted sql

-- changeset filipelopes:005 comment:Adiciona coluna name na tabela db_connections
ALTER TABLE db_connections ADD COLUMN name VARCHAR(255);