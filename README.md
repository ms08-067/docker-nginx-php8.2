## Deployment

The `docker-compose.*.yml` files can be used as base for stack deployments. Some environment variables have to be set in order to work properly.


## Working locally

1. Build the custom image (this step needs to be redone, everytime you change something in the image):
 `docker-compose -f docker-compose.local.yml build`
2. Deploy the containers locally: `UID=(id -u) GID=(id -g) docker-compose -f docker-compose.local.yml up`
3. Open http://localhost to see if it runs correctly
4. For executing commands in the docker container use: `docker exec hocphp <my command here>`
5. Local changes in files will be propagated to the container due to the Docker mount
6. to tear down the container and their associated volumes use `docker-compose -f docker-compose.local.yml down -v`
# docker-nginx-php8.2
# docker-nginx-php8.2
