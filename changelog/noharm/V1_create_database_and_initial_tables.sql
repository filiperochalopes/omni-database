-- liquibase formatted sql

-- changeset filipelopes:001
CREATE DATABASE IF NOT EXISTS noharm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- changeset filipelopes:002
CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    uf CHAR(2),
    phone VARCHAR(20),
    email VARCHAR(255),
    gdrive_backup_folder_id VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- changeset filipelopes:003
CREATE TABLE db_connections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    host VARCHAR(255) NOT NULL,
    port VARCHAR(10),
    username VARCHAR(255),
    password VARBINARY(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- changeset filipelopes:004
CREATE TABLE installations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_host VARCHAR(255),
    url VARCHAR(255),
    version VARCHAR(50),
    healthy BOOLEAN,
    last_checked_at DATETIME,
    next_version VARCHAR(50),
    should_update BOOLEAN,
    contact_id INT,
    db_connection_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (contact_id) REFERENCES contacts(id),
    FOREIGN KEY (db_connection_id) REFERENCES db_connections(id)
);