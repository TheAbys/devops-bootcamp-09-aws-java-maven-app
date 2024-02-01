#!/usr/bin/env bash

# $1 is the first argument passed to the bash script
export IMAGE=$1
docker-compose -f docker-compose.yaml up --detach
echo "success"