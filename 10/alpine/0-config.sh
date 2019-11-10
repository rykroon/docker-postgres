
sql() {
	psql -U $POSTGRES_USER -d template1 -c "$1";
}

# Since all databases are created from template1, 
# make sure that only the superuser can connect to the template1 database
sql "REVOKE ALL ON DATABASE template1 FROM PUBLIC;"


# By default new schemas do not grant any privileges.
# Change the public schema to behave in the same manner.
sql "REVOKE ALL ON SCHEMA public FROM PUBLIC;"


# Create roles
sql "CREATE ROLE adminuser CREATEDB CREATEROLE;"
sql "CREATE ROLE cruduser;"
sql "CREATE ROLE rwuser;"
sql "CREATE ROLE readuser;"


# Grant ALL privileges to adminuser. This is the 
# role that should be used to create tables
sql "GRANT ALL ON SCHEMA public TO adminuser;"


# Grant SELECT, INSERT, UPDATE, DELETE (CRUD) privileges to the cruduser role
sql "GRANT USAGE ON SCHEMA public TO cruduser;"
sql "ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cruduser;"
sql "ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT USAGE ON SEQUENCES TO cruduser;"


# Grant SELECT, INSERT, UPDATE (Read + Write) privileges to the rwuser role
sql "GRANT USAGE ON SCHEMA public TO rwuser;"
sql "ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO cruduser;"
sql "ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT USAGE ON SEQUENCES TO cruduser;"


# Grant SELECT (read) privileges to the readuser role
sql "GRANT USAGE ON SCHEMA public TO readuser;"
sql "ALTER DEFAULT PRIVILEGES FOR ROLE adminuser IN SCHEMA public GRANT SELECT ON TABLES TO readuser;"


#re-create the databases from the new template
sql "DROP DATABASE postgres;"
sql "CREATE DATABASE postgres;"

sql "DROP DATABASE $POSTGRES_DB;"
sql "CREATE DATABASE $POSTGRES_DB;"


#Change password encryption from md5 to scram-sha-256
sed -i 's/#password_encryption.*/password_encryption = scram-sha-256/' var/lib/postgresql/data/postgresql.conf

#Reload configuration file
sql "SELECT pg_reload_conf();"


#If no password is provided make the default password the same as the user
if [ "$POSTGRES_PASSWORD" == "" ]
then
        export POSTGRES_PASSWORD=$POSTGRES_USER
fi

#Change the password for the superuser
sql "ALTER ROLE $POSTGRES_USER WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';"


#Create Admin user if applicable
if [ "$PG_ADMIN_USER" != "" ]
then
	#Set default password to the username
	if [ "$PG_ADMIN_PASSWORD" == "" ]
	then
		export PG_ADMIN_PASSWORD=$PG_ADMIN_USER
	fi

	sql "CREATE ROLE $PG_ADMIN_USER LOGIN NOINHERIT ENCRYPTED PASSWORD '$PG_ADMIN_PASSWORD';"
	sql "GRANT adminuser TO $PG_ADMIN_USER;"
fi


#Create crud user if applicable
if [ "$PG_CRUD_USER" != "" ]
then
	#Set default password to username
	if [ "$PG_CRUD_PASSWORD" == "" ]
	then
		export PG_CRUD_PASSWORD=$PG_CRUD_USER
	fi

	sql "CREATE ROLE $PG_CRUD_USER LOGIN ENCRYPTED PASSWORD '$PG_CRUD_PASSWORD';"
	sql "GRANT cruduser TO $PG_CRUD_USER;"
fi


#Create crud user if applicable
if [ "$PG_RW_USER" != "" ]
then
	#Set default password to username
	if [ "$PG_RW_PASSWORD" == "" ]
	then
		export PG_RW_PASSWORD=$PG_RW_USER
	fi

	sql "CREATE ROLE $PG_RW_USER LOGIN ENCRYPTED PASSWORD '$PG_RW_PASSWORD';"
	sql "GRANT cruduser TO $PG_RW_USER;"
fi


#Create read user if applicable
if [ "$PG_READ_USER" != "" ]
then
	if [ "$PG_READ_PASSWORD" == "" ]
	then
		export PG_READ_PASSWORD=$PG_READ_USER
	fi

	sql "CREATE ROLE $PG_READ_USER LOGIN ENCRYPTED PASSWORD '$PG_READ_PASSWORD';"
	sql "GRANT readuser TO $PG_READ_USER;"
fi


#Change authentication methodfrom 'trust' to 'scram-sha-256'
sed -i '/^#/!s/trust/scram-sha-256/' var/lib/postgresql/data/pg_hba.conf

