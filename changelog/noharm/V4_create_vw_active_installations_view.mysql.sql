-- liquibase formatted sql

-- changeset filipelopes:create-vw-active-installations-view
-- This script creates the vw_active_installations view to display active installations with contact information
-- Includes the new update_schedule_time column added in V3
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
    `c`.`email` AS `email`
FROM
    (`installations` `i`
LEFT JOIN `contacts` `c` ON
    (`i`.`contact_id` = `c`.`id`))
WHERE
    `i`.`active` = 1;
