-- Create database
DROP DATABASE IF EXISTS DamsApp;
CREATE DATABASE DamsApp;

--Postgres doesn’t support USE DamsApp;
--USE DamsApp;

-- Drop tables if they exist
DROP TABLE IF EXISTS group_members;
--DROP TABLE IF EXISTS scim_groups;
DROP TABLE IF EXISTS scim_user_roles;
DROP TABLE IF EXISTS scim_user_emails;
DROP TABLE IF EXISTS scim_users;

-- Create scim_users table
CREATE TABLE scim_users (
    id CHAR(36) PRIMARY KEY,
    external_id VARCHAR(255),
    user_name VARCHAR(255),
    active BOOLEAN,
    formatted VARCHAR(255),
    family_name VARCHAR(255),
    given_name VARCHAR(255),
    resource_type VARCHAR(50),
    created VARCHAR(50),
    last_modified VARCHAR(50)
);

-- Create scim_user_emails table
CREATE TABLE scim_user_emails (
    user_id CHAR(36),
    value VARCHAR(255),
    type VARCHAR(50),
    is_primary BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES scim_users(id)
);

-- Create scim_user_roles table
CREATE TABLE scim_user_roles (
    user_id CHAR(36),
    roles VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES scim_users(id)
);

-- Create scim_groups table
CREATE TABLE scim_groups (
    id CHAR(36) PRIMARY KEY,
    display_name VARCHAR(255) UNIQUE NOT NULL,
    external_id VARCHAR(255),
    created TIMESTAMP,
    --created DATETIME,  Postgres uses TIMESTAMP not DATETIME
    last_modified TIMESTAMP,
    --last_modified DATETIME,
    resource_type VARCHAR(50)
);

-- Create group_members table
CREATE TABLE group_members (
    group_id CHAR(36),
    member_id VARCHAR(255),
    FOREIGN KEY (group_id) REFERENCES scim_groups(id)
);

-- Insert sample scim_users
INSERT INTO scim_users VALUES
('11111111-aaaa-bbbb-cccc-111111111111', 'ext-user-001', 'user.alpha', true, 'Alpha User', 'User', 'Alpha', 'User', '2025-11-17T10:00:00Z', '2025-11-17T10:00:00Z'),
('22222222-bbbb-cccc-dddd-222222222222', 'ext-user-002', 'user.beta', false, 'Beta User', 'User', 'Beta', 'User', '2025-11-17T11:00:00Z', '2025-11-17T11:00:00Z'),
('33333333-cccc-dddd-eeee-333333333333', 'ext-user-003', 'user.gamma', true, 'Gamma User', 'User', 'Gamma', 'User', '2025-11-17T12:00:00Z', '2025-11-17T12:00:00Z');

-- Insert sample scim_user_emails
INSERT INTO scim_user_emails VALUES
('11111111-aaaa-bbbb-cccc-111111111111', 'alpha.user@example.com', 'work', true),
('22222222-bbbb-cccc-dddd-222222222222', 'beta.user@example.com', 'home', false),
('33333333-cccc-dddd-eeee-333333333333', 'gamma.user@example.com', 'work', true);

-- Insert sample scim_user_roles
INSERT INTO scim_user_roles VALUES
('11111111-aaaa-bbbb-cccc-111111111111', 'developer'),
('22222222-bbbb-cccc-dddd-222222222222', 'analyst'),
('33333333-cccc-dddd-eeee-333333333333', 'product_owner');

-- Insert sample scim_groups
INSERT INTO scim_groups VALUES
('aaaa1111-bbbb-2222-cccc-3333dddd4444', 'Engineering Guild', 'group-eng-007', '2025-11-17 12:00:00', '2025-11-17 12:00:00', 'Group'),
('bbbb2222-cccc-3333-dddd-4444eeee5555', 'Data Analysts', 'group-data-009', '2025-11-17 13:00:00', '2025-11-17 13:00:00', 'Group'),
('cccc3333-dddd-4444-eeee-5555ffff6666', 'Product Owners', 'group-prod-011', '2025-11-17 14:00:00', '2025-11-17 14:00:00', 'Group');

-- Insert sample group_members
INSERT INTO group_members VALUES
('aaaa1111-bbbb-2222-cccc-3333dddd4444', '11111111-aaaa-bbbb-cccc-111111111111'),
('bbbb2222-cccc-3333-dddd-4444eeee5555', '22222222-bbbb-cccc-dddd-222222222222'),
('cccc3333-dddd-4444-eeee-5555ffff6666', '33333333-cccc-dddd-eeee-333333333333');
