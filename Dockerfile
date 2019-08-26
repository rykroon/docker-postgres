From postgres:11-alpine

COPY roles.sql docker-entrypoint-initdb.d
COPY zauth.sh docker-entrypoint-initdb.d

