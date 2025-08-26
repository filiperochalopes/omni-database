-- liquibase formatted sql

-- changeset filipelopes:add-installation-mode-to-installations
ALTER TABLE installations
ADD COLUMN installation_mode VARCHAR(20) DEFAULT 'standalone';