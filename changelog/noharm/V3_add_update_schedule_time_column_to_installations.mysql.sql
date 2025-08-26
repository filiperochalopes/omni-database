-- liquibase formatted sql

-- changeset filipelopes:add-update-schedule-time-column-to-installations
-- This script adds the update_schedule_time column to the installations table
-- The TIME type stores time values in the format HH:MM:SS (e.g., '14:30:00' for 2:30 PM)
ALTER TABLE installations 
ADD COLUMN update_schedule_time TIME 
COMMENT 'Scheduled time for automatic updates in HH:MM:SS format';
