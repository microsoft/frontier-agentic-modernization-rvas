#!/bin/bash
# This script ensures the photoalbum user is created in Oracle XE

# Wait for Oracle to be fully ready
echo "Waiting for Oracle to be ready..."
sleep 30

# Connect to Oracle as SYSTEM and create the photoalbum user
sqlplus -s system/photoalbum@//localhost:1521/XE <<EOF
-- Create photoalbum user if it doesn't exist
DECLARE
    user_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO user_exists FROM dba_users WHERE username = 'PHOTOALBUM';
    
    IF user_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER photoalbum IDENTIFIED BY photoalbum';
        EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO photoalbum';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO photoalbum';
        EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO photoalbum';
        EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO photoalbum';
        EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO photoalbum';
        EXECUTE IMMEDIATE 'ALTER USER photoalbum DEFAULT TABLESPACE USERS';
        
        DBMS_OUTPUT.PUT_LINE('User photoalbum created successfully');
    ELSE
        DBMS_OUTPUT.PUT_LINE('User photoalbum already exists');
    END IF;
END;
/

exit;
EOF

echo "User creation script completed."