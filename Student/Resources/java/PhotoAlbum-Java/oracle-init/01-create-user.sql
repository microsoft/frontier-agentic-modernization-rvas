-- This script runs automatically when Oracle XE container starts
-- It creates the photoalbum user and grants necessary privileges

ALTER SESSION SET "_ORACLE_SCRIPT"=true;

-- Create photoalbum user
CREATE USER photoalbum IDENTIFIED BY photoalbum;

-- Grant system privileges
GRANT CONNECT TO photoalbum;
GRANT RESOURCE TO photoalbum;
GRANT DBA TO photoalbum;
GRANT CREATE SESSION TO photoalbum;
GRANT CREATE TABLE TO photoalbum;
GRANT CREATE SEQUENCE TO photoalbum;
GRANT CREATE VIEW TO photoalbum;
GRANT CREATE PROCEDURE TO photoalbum;
GRANT CREATE TRIGGER TO photoalbum;
GRANT CREATE TYPE TO photoalbum;
GRANT CREATE SYNONYM TO photoalbum;
GRANT UNLIMITED TABLESPACE TO photoalbum;

-- Grant object privileges needed by Hibernate
GRANT SELECT ANY DICTIONARY TO photoalbum;
GRANT CREATE ANY INDEX TO photoalbum;
GRANT ALTER ANY INDEX TO photoalbum;
GRANT DROP ANY INDEX TO photoalbum;

-- Set default and temporary tablespace
ALTER USER photoalbum DEFAULT TABLESPACE USERS;
ALTER USER photoalbum TEMPORARY TABLESPACE TEMP;

-- Commit the changes
COMMIT;

EXIT;