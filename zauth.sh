
sql() {
	psql -U $POSTGRES_USER -d template1 -c "$1";
}


#re-create the database from the new template
sql "DROP DATABASE IF EXISTS postgres;"
sql "DROP DATABASE IF EXISTS $POSTGRES_DB;"
sql "CREATE DATABASE $POSTGRES_DB WITH OWNER adminuser;"



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
if [ "$ADMIN_USER" != "" ]
then
	#Set default password to the username
	if [ "$ADMIN_PASSWORD" == "" ]
	then
		export ADMIN_PASSWORD=$ADMIN_USER
	fi

	sql "CREATE ROLE $ADMIN_USER LOGIN NOINHERIT ENCRYPTED PASSWORD '$ADMIN_PASSWORD';"
	sql "GRANT adminuser TO $ADMIN_USER;"
fi


#Create crud user if applicable
if [ "$CRUD_USER" != "" ]
then
	#Set default password to username
	if [ "$CRUD_PASSWORD" == "" ]
	then
		export CRUD_PASSWORD=$CRUD_USER
	fi

	sql "CREATE ROLE $CRUD_USER LOGIN ENCRYPTED PASSWORD '$CRUD_PASSWORD';"
	sql "GRANT cruduser TO $CRUD_USER;"
fi



#Create read user if applicable
if [ "$READ_USER" != "" ]
then
	if [ "$READ_PASSWORD" == "" ]
	then
		export READ_PASSWORD=$READ_USER
	fi

	sql "CREATE ROLE $READ_USER LOGIN ENCRYPTED PASSWORD '$READ_PASSWORD';"
	sql "GRANT readuser TO $READ_USER;"
fi



#Change authentication from trust to sha-256
sed -i '/^#/!s/trust/scram-sha-256/' var/lib/postgresql/data/pg_hba.conf



