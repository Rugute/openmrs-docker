# Openmrs platform docker
This is a produces a docker image with openmrs platform 2.1.2 with openmrs rest services module version 2.24.0
Rename the main.env.example to main.env and use
```docker run --env-file=main.env```
to override the env variables defined in the docker file  refer to http://ryannickel.com/html/playing_with_docker_enviornment_variables.html


# last working image hash
10.50.80.56:5005/openmrs:2.1.2@sha256:3e4fd253ff49d86d753903fa45df3f717377665fefcc5b8de225b7c8de2cbcce