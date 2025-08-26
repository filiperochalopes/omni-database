-- liquibase formatted sql

-- changeset filipelopes:add-installation-id-to-notifications
-- creates a new column 'installation_id' in the notifications table
-- and modifies the unique index to include the new column
ALTER TABLE notifications
ADD COLUMN installation_id INTEGER;

ALTER TABLE notifications
DROP INDEX uniq_notification_constraint;

CREATE UNIQUE INDEX uniq_notification_constraint
ON notifications (channel, version, subject, installation_id);

-- changeset filipelopes:add-active-to-installations
-- creates a new column 'active' in the installations table
ALTER TABLE installations
ADD COLUMN active BOOLEAN DEFAULT true;