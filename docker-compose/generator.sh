#!/bin/bash


#version: '3.8'
# services:
# # SQL file to update
# SQL_FILE="./database/oai_db3.sql"

# # Backup existing SQL file
# cp $SQL_FILE "${SQL_FILE}.bak"

# # Split the original SQL file at line 153 and line 308
# head -n 153 $SQL_FILE > temp1.sql
# tail -n +154 $SQL_FILE | head -n 155 > temp2.sql
# tail -n +309 $SQL_FILE > temp3.sql

#     AUTH_SUBSCRIPTION_ENTRY=$(cat <<EOL
# ('$IMSI', '5G_AKA', '0C0A34601D4F07677303652C0462535B', '0C0A34601D4F07677303652C0462535B', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', '63bfa50ee6523365ff14c1f45f88737d', NULL, NULL, NULL, NULL, '$IMSI'),
# EOL
#     )

#     SESSION_MANAGEMENT_ENTRY=$(cat <<EOL
# INSERT INTO \`SessionManagementSubscriptionData\` (\`ueid\`, \`servingPlmnid\`, \`singleNssai\`, \`dnnConfigurations\`) VALUES 
# ('$IMSI', '20895', '{\"sst\": 222, \"sd\": \"123\"}','{\"default\":{\"pduSessionTypes\":{\"defaultSessionType\": \"IPV4\"},\"sscModes\": {\"defaultSscMode\": \"SSC_MODE_1\"},\"5gQosProfile\": {\"5qi\": 6,\"arp\":{\"priorityLevel\": 1,\"preemptCap\": \"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"100Mbps\", \"downlink\":\"100Mbps\"}}}');
# EOL
#     )

#     # Append the SQL entries to the respective temp files
#     echo "$AUTH_SUBSCRIPTION_ENTRY" >> temp1.sql
#     echo "$SESSION_MANAGEMENT_ENTRY" >> temp2.sql

# # Remove the trailing comma from the last AUTH_SUBSCRIPTION_ENTRY
# sed -i '$ s/,$/;/' temp1.sql

# # Combine the temp files to create the updated SQL file
# cat temp1.sql temp2.sql temp3.sql > $SQL_FILE

# # Clean up temp files
# rm temp1.sql temp2.sql temp3.sql


#CONSIDERING NO GNB TO BE PRESENT



# Base MSIN and IP address values
BASE_MSIN=31
BASE_IP=156
BASE_GNBID=1

# Prompt user for the number of instances to create
echo -n "How many instances do you want to create? : "
read NUM_INSTANCES

COMPOSE_FILE="docker-compose-gnbsim.yaml"
cat <<EOL >> $COMPOSE_FILE
services:
EOL

# Generate docker-compose files for each instance and update SQL file
for((i=0;i<NUM_INSTANCES;i++));
do
    MSIN=$(printf "%010d" $((BASE_MSIN + i)))
    IP_SUFFIX=$((BASE_IP + i))
    gnbid=$((BASE_GNBID + i))
    COMPOSE_FILE="docker-compose-gnbsim.yaml"      #_$((i+1))
    
    cat <<EOL >> $COMPOSE_FILE
  gnbsim$((i+1)):
    container_name: gnbsim$((i+1))
    image: gnbsim:latest
    privileged: true
    environment:
        - MCC=208
        - MNC=95
        - GNBID=$gnbid
        - TAC=0x00a000
        - SST=222
        - SD=00007b
        - PagingDRX=v32
        - RANUENGAPID=0
        - IMEISV=35609204079514
        - MSIN=$MSIN
        - RoutingIndicator=1234
        - ProtectionScheme=null
        - KEY=0C0A34601D4F07677303652C0462535B
        - OPc=63bfa50ee6523365ff14c1f45f88737d
        - DNN=default
        - URL=http://www.asnt.org:8080/
        - NRCellID=1
        - USE_FQDN=no
        - NGAPPeerAddr=192.168.70.132
        - GTPuLocalAddr=192.168.70.$IP_SUFFIX
        - GTPuIFname=eth0
    networks:
        public_net:
            ipv4_address: 192.168.70.$IP_SUFFIX
    healthcheck:
        test: /bin/bash -c "ip address show dev gtp-gnb"
        interval: 10s
        timeout: 5s
        retries: 5
EOL
done
cat <<EOL >> $COMPOSE_FILE
networks:
  public_net:
    external:
      name: demo-oai-public-net
EOL
sleep 2
for ((i=0; i<NUM_INSTANCES; i++)); do
  docker compose -f $COMPOSE_FILE up -d gnbsim$((i+1))
  sleep 6
done