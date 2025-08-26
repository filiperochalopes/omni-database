-- liquibase formatted sql

-- changeset filipelopes:update-vw-active-installations-add-gdrive-backup-folder-id
-- This script updates the vw_active_installations view to include the gdrive_backup_folder_id column from contacts table
CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `vw_active_installations` AS
SELECT
    `i`.`id` AS `installation_id`,
    `c`.`name` AS `contact_name`,
    `i`.`server_host` AS `server_host`,
    `i`.`url` AS `url`,
    `i`.`version` AS `version`,
    `i`.`next_version` AS `next_version`,
    `i`.`should_update` AS `should_update`,
    `i`.`installation_mode` AS `installation_mode`,
    `i`.`update_schedule_time` AS `update_schedule_time`,
    `i`.`updated_at` AS `installation_updated_at`,
    `c`.`city` AS `city`,
    `c`.`uf` AS `uf`,
    `c`.`phone` AS `phone`,
    `c`.`email` AS `email`,
    `c`.`gdrive_backup_folder_id` AS `gdrive_backup_folder_id`
FROM
    (`installations` `i`
LEFT JOIN `contacts` `c` ON
    (`i`.`contact_id` = `c`.`id`))
WHERE
    `i`.`active` = 1;
