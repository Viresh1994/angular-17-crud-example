-- ====================================================================
-- Create database if not exists
-- ====================================================================
DO $$ 
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'scimdb') THEN
      CREATE DATABASE scimdb;
   END IF;
END $$;

-- Connect to the database (psql meta-command)
\c scimdb;

-- ====================================================================
-- Clean up existing objects (safe for re-runs)
-- ====================================================================
DROP TABLE IF EXISTS group_members,
                     scim_user_roles,
                     scim_user_emails,
                     scim_groups,
                     scim_users
CASCADE;

DROP FUNCTION IF EXISTS set_scim_users_last_modified() CASCADE;
DROP FUNCTION IF EXISTS set_scim_groups_last_modified() CASCADE;

-- ====================================================================
-- Extensions
-- ====================================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ====================================================================
-- TABLE: scim_users
-- ====================================================================
CREATE TABLE scim_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    external_id   VARCHAR(255),
    user_name     VARCHAR(255) NOT NULL,
    active        BOOLEAN NOT NULL DEFAULT TRUE,

    formatted     VARCHAR(255),
    family_name   VARCHAR(255),
    given_name    VARCHAR(255),

    resource_type VARCHAR(100) NOT NULL DEFAULT 'User',

    created       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_modified TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_scim_users_username    UNIQUE (user_name),
    CONSTRAINT uq_scim_users_external_id UNIQUE (external_id)
);

-- Indexes for scim_users
CREATE INDEX idx_scim_users_active
    ON scim_users (active);

CREATE INDEX idx_scim_users_last_modified
    ON scim_users (last_modified);

-- Trigger function for scim_users.last_modified
CREATE OR REPLACE FUNCTION set_scim_users_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for scim_users.last_modified
CREATE TRIGGER trg_scim_users_last_modified
BEFORE UPDATE ON scim_users
FOR EACH ROW
EXECUTE FUNCTION set_scim_users_last_modified();

-- ====================================================================
-- TABLE: scim_groups
-- ====================================================================
CREATE TABLE scim_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    display_name VARCHAR(255) NOT NULL,
    external_id  VARCHAR(255),

    created       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_modified TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    resource_type VARCHAR(100) NOT NULL DEFAULT 'Group',

    CONSTRAINT uq_scim_groups_displayname UNIQUE (display_name),
    CONSTRAINT uq_scim_groups_external_id UNIQUE (external_id)
);

-- Indexes for scim_groups
CREATE INDEX idx_scim_groups_last_modified
    ON scim_groups (last_modified);

-- Trigger function for scim_groups.last_modified
CREATE OR REPLACE FUNCTION set_scim_groups_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for scim_groups.last_modified
CREATE TRIGGER trg_scim_groups_last_modified
BEFORE UPDATE ON scim_groups
FOR EACH ROW
EXECUTE FUNCTION set_scim_groups_last_modified();

-- ====================================================================
-- TABLE: scim_user_emails
-- ====================================================================
CREATE TABLE scim_user_emails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES scim_users(id)
        ON DELETE CASCADE,

    value VARCHAR(255) NOT NULL,  -- email address
    type  VARCHAR(50),           -- e.g. 'work', 'home'
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT uq_scim_user_email_unique_per_user
        UNIQUE (user_id, value)
);

-- Indexes for scim_user_emails
CREATE INDEX idx_scim_user_emails_userid
    ON scim_user_emails (user_id);

CREATE INDEX idx_scim_user_emails_primary
    ON scim_user_emails (is_primary);

-- ====================================================================
-- TABLE: scim_user_roles
-- ====================================================================
CREATE TABLE scim_user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES scim_users(id)
        ON DELETE CASCADE,

    roles VARCHAR(100) NOT NULL,  -- e.g. 'ADMIN', 'USER', 'MANAGER'

    CONSTRAINT uq_scim_user_roles UNIQUE (user_id, roles)
);

-- Index for scim_user_roles
CREATE INDEX idx_scim_user_roles_userid
    ON scim_user_roles (user_id);

-- ====================================================================
-- TABLE: group_members
-- ====================================================================
CREATE TABLE group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    group_id UUID NOT NULL
        REFERENCES scim_groups(id)
        ON DELETE CASCADE,

    member_id VARCHAR(255) NOT NULL,  -- SCIM member id (often a user id, stored as string)

    CONSTRAINT uq_group_member UNIQUE (group_id, member_id)
);

-- Indexes for group_members
CREATE INDEX idx_group_members_group
    ON group_members (group_id);

CREATE INDEX idx_group_members_member
    ON group_members (member_id);
