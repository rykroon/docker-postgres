--Switch to the template1 database
\c template1 

--Create roles adminuser, cruduser, and readuser
CREATE ROLE adminuser CREATEDB CREATEROLE;
CREATE ROLE cruduser;
CREATE ROLE readuser;


--Revoke all database privileges from template1 (only the super user can access template1)
REVOKE ALL ON DATABASE template1 FROM PUBLIC;


-- Revoke all privileges on the public schema 
REVOKE ALL ON SCHEMA public FROM PUBLIC;


--Grant usage, and select privileges to the readuser role
GRANT USAGE ON SCHEMA public TO readuser;
ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT SELECT ON TABLES TO readuser;


--Grant usage, select, insert, update, delete privileges to the cruduser role
GRANT USAGE ON SCHEMA public TO cruduser;
ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cruduser;


--Grant all privileges to the adminuser
GRANT ALL ON SCHEMA public TO adminuser;


