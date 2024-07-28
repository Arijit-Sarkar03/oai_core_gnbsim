#!/bin/bash
read -p "How many instances do you want to spin up? " instances

for((i=0;i<instances;i++)); do
	docker compose -f docker-compose-gnbsim-original.yaml up gnbsim$((i+1)) -d
	sleep 10
done
