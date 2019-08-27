From postgres:11-alpine

COPY alfa_template1.sql docker-entrypoint-initdb.d
COPY bravo_auth_and_users.sh docker-entrypoint-initdb.d

