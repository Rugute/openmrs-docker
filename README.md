# Openmrs platform docker

This is a produces a docker image with openmrs platform 2.6.0 with openmrs rest services module version 2.24.0
Rename the main.env.example to main.env and use
`docker run --env-file=main.env`
to override the env variables defined in the docker file refer to http://ryannickel.com/html/playing_with_docker_enviornment_variables.html

# last working image hash

10.50.80.56:5005/openmrs:2.1.2@sha256:b5dbaa216b57afec1a7bb5c3721b59a83292463da6fe9adaf94158cfbf27dfde

# Publishing to Docker

docker buildx build --push --tag erugut/openmrs:openmrs-2.6.0 --platform=linux/arm64,linux/amd64 .

# Run docker

docker run -p 8080:8080 --env-file=main.env erugut/ampath-ioms:openmrs-2.6.0

# Stop Openmrs 2.4 Prod

sudo docker stop amrs-task-f758b089-f333-5127-02ca-6744ded4a32b
sudo docker run --restart=no ampathke/openmrs2.4.0:prod-tc7-jdk8-1.5
