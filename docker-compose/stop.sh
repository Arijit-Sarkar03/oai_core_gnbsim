#!/bin/bash

# Number of instances to stop
read -p "Number of instances you created : " NUM_INSTANCES

# Loop to stop each instance
for i in $(seq 1 $NUM_INSTANCES)
do
    COMPOSE_FILE="docker-compose-gnbsim_$i.yaml"
    docker-compose -f $COMPOSE_FILE down
    echo "Stopped gnbsim_$i."
done
