docker rmi rykroon/postgres:10
docker rmi rykroon/postgres:10-alpine
docker rmi rykroon/postgres:11
docker rmi rykroon/postgres:11-alpine

docker build --no-cache --pull -t rykroon/postgres:10 10/
docker build --no-cache --pull -t rykroon/postgres:10-alpine 10/alpine/
docker build --no-cache --pull -t rykroon/postgres:11 11/
docker build --no-cache --pull -t rykroon/postgres:11-alpine 11/alpine/

