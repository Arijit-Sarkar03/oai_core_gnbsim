#!/bin/bash

# Number of instances to start
read -p "How many instances did you start" NUM_INSTANCES

# Loop to start each instance with a delay
for i in $(seq 1 $NUM_INSTANCES)
do
    COMPOSE_FILE="docker-compose-gnbsim_$i.yaml"
    docker-compose -f $COMPOSE_FILE up -d
    echo "Started gnbsim_$i with MSIN and IP address incremented."
    sleep 20
done
