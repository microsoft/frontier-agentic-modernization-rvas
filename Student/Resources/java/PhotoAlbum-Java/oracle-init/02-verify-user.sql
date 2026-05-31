-- Verification script to check if photoalbum user exists
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

-- Check if user exists
SELECT username, account_status, default_tablespace 
FROM dba_users 
WHERE username = 'PHOTOALBUM';

-- Show granted privileges
SELECT grantee, privilege 
FROM dba_sys_privs 
WHERE grantee = 'PHOTOALBUM';

EXIT;