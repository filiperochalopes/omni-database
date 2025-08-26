-- liquibase formatted sql

-- changeset filipelopes:create-notifications-table
-- This script creates the notifications table to store notification messages.
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    channel VARCHAR(50) NOT NULL,
    version VARCHAR(20),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- changeset filipelopes:add-unique-index-on-notifications
-- This index ensures that there are no duplicate notifications for the same channel, version, and subject.
CREATE UNIQUE INDEX uniq_notification_constraint 
ON notifications(channel, version, subject);