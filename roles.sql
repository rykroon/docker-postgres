--Switch to the template1 database
\c template1 

--Create roles adminuser, cruduser, and readuser
CREATE ROLE adminuser CREATEDB CREATEROLE;
CREATE ROLE cruduser;
CREATE ROLE readuser;


--Revoke all privileges from the public role
--REVOKE ALL ON DATABASE template1 FROM public;
REVOKE ALL ON SCHEMA public FROM public;


--Grant connect, usage, and select privileges to the readuser role
--GRANT CONNECT ON DATABASE template1 TO readuser;
GRANT USAGE ON SCHEMA public TO readuser;
ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT SELECT ON TABLES TO readuser;


--Grant connect, usage, Select, Insert, Update, Delete privileges to the cruduser role
--GRANT CONNECT ON DATABASE template1 TO cruduser;
GRANT USAGE ON SCHEMA public TO cruduser;
ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cruduser;


--Grant all privileges to the adminuser
--GRANT ALL ON DATABASE template1 TO adminuser;
GRANT ALL ON SCHEMA public TO adminuser;


