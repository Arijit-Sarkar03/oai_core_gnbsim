
# OpenAirInterface v1.4.0 - Core and testing with RAN simulator GNBSIM
The following setup is taken from the repo : https://github.com/5g-ucl-idrbt/oai-core

You can check that out for a virtualised core and a physical USRP setup
## Description
The target [Architectural diagram](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/raw/master/docs/images/5gCN_gnbsim.jpg) has two parts. `(a) Virtualized 5G Core` and `(b) RAN simulator GNBSIM`. This tutorial is about how to create Virtualized 5G Core VM along with RAN simulator `GNBSIM`

## Tested Setup
We have used this on :
- `Intel Core I7 13th gen system`
- `AMD Ryzen 5 3rd gen system`
- `Ubuntu 20.04 LTS`
- `Ubuntu 22.04 LTS (Jammy Jellyfish)`
- `Ubuntu 24.04 LTS (Noble Numbat)`

## Recommended Settings
First Install Oracle Virtual Box and extension pack. In this case we have used 7.0.
- `Ubuntu 22.04 VM` with 
- `4vCPUs`, & `4GB RAM`
## Docker installation
Follow these steps to install docker engine and docker compose latest version:

```
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
```
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```
To check for successfull installation of docker engine
```
sudo docker --version
```
Now install docker compose:
```
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
```
sudo chmod +x /usr/local/bin/docker-compose

docker compose version
```
```
sudo groupadd docker
```
To not use sudo repeatatively while using docker, run this command
```
sudo usermod -aG docker $USER
```
`$USER`should be replaced with your machine username, to know your username run the command in `whoami` in your terminal.

#### Commands to be executed 
To enable packet forwarding from gnbsim to core
```
sudo sysctl net.ipv4.ip_forward=1
sudo iptables -P FORWARD ACCEPT
```

## Git clone
clone the repository by executing the command:
```
git clone https://github.com/Arijit-Sarkar03/oai_core_gnbsim.git
```

## Import docker images
- change directory to component by using `cd component` and Recombine to load all the docker images. The steps are mentioned [here](https://github.com/Arijit-Sarkar03/oai_core_gnbsim/blob/main/component/README.md)
- `cd ../docker-compose`
- Give executable permission to all the shell scripts by using the command: `find ./ -type f -print |grep ".sh"|xargs sudo chmod -v 777`

## Single Host setup
This setup deployment is in a single host VM which means the `oai-core` and the `gnbsim` is in the same VM

Follow the steps mentioned below:

### Execute with docker compose
Edit required changes in environment variables of `docker-compose-basic-nrf.yaml` file
- Note: the `docker-compose-basic-nrf.yaml` files is already set up to be compatible with the gnbsim, hence no changes are required.
To achieve compatibility with the gnbsim we have modified the following in the `docker-compose-basic-nrf.yaml` file:
  - comment all occurences of `HTTP_PROXY` and `HTTPS_PROXY` if you are not in a proxy based environment
  - Go to the service descriptions of `oai-amf` and fill up the appropriate values
  - Provide same `MCC `and` MNC` in the service descriptions of `oai-spgwu`
  - Search for the comments (i.e. #) to identify the values which might require adjustments

### Start core services
change directory to docker  compose i.e `cd docker-compose`

Now execute the following command to deploy the core services
```
sudo python3 core-network.py --type start-basic --scenario 1
```
If any container spins up in an `unhealthy` state, Try stopping the services using the below and command and again deploy the core. This should fix the error
- Note: if the problem persists try to debug using command `docker logs <container_name>`
### Stop the services using the command:
```
sudo python3 core-network.py --type stop-basic
```


## Provisioning Sim information
change directory to database by executing `cd database`

edit the `oai_db3.sql` file

- In "AuthenticationSubscription" Table Sample add a new value as follows. (`ueid=UE.IMSI`, `authenticationMethod` , `encPermanentKey=UE.key`, `protectionParameterId=UE.key`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey=OperatorKey_OAI-AMF`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi=UE.IMSI`)

- In "SessionManagementSubscriptionData" Table Sample add a new value as follows. (`ueid=UE.IMSI`, `servingPlmnid=UE.MCC_MNC`, `singleNssai=SST,SD`, `dnnConfigurations`)

```
Sample

#Under AuthenticationSubscription

('208950000000031', '5G_AKA', '0C0A34601D4F07677303652C0462535B', '0C0A34601D4F07677303652C0462535B', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', '63bfa50ee6523365ff14c1f45f88737d', NULL, NULL, NULL, NULL, '208950000000031'),

#Under SessionManagementSubscriptionData

INSERT INTO `SessionManagementSubscriptionData` (`ueid`, `servingPlmnid`, `singleNssai`, `dnnConfigurations`) VALUES 
('208950000000031', '20895', '{\"sst\": 222, \"sd\": \"123\"}','{\"default\":{\"pduSessionTypes\":{\"defaultSessionType\": \"IPV4\"},\"sscModes\": {\"defaultSscMode\": \"SSC_MODE_1\"},\"5gQosProfile\": {\"5qi\": 6,\"arp\":{\"priorityLevel\": 1,\"preemptCap\": \"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"100Mbps\", \"downlink\":\"100Mbps\"}}}');
```
- Note: tally all the env variables of `gnbsim` with `oai-amf`,`oai-spgwu` and `oai_db3` for successfull network connection
Now restart the core to enable SIM registration.



## Getting a gnbsim image
You have the choice:
- Building a `gnbsim` docker image
Please clone the repository outside of the `oai_core_gnbsim` workspace.
```
$ cd
$ git clone https://gitlab.eurecom.fr/kharade/gnbsim.git
$ cd gnbsim
$ docker build --tag gnbsim:latest --target gnbsim --file docker/Dockerfile.ubuntu.22.04 .

```
OR
- you can pull a pre-built image
```
docker pull rohankharade/gnbsim
docker image tag rohankharade/gnbsim:latest gnbsim:latest
```
### Executing the `gnbsim` scenario
- The configuration parameters are preconfigured in `docker-compose-gnbsim.yaml` and one can modify it for testing purposes.

###  Launch gnbsim docker service
After starting the core, you need to start the gnbsim docker service using the command:
```
docker-compose -f docker-compose-gnbsim.yaml up -d gnbsim
```
let the container spin up to be healthy, 
```
docker-compose-host $: docker-compose -f docker-compose-gnbsim.yaml ps -a
Name               Command                  State       Ports
--------------------------------------------------------------
gnbsim   /gnbsim/bin/entrypoint.sh  ...   Up (healthy)

```
After launching gnbsim, make sure all services status are healthy -

```
Sample :- 

docker-compose-host $: docker ps -a
CONTAINER ID   IMAGE                           COMMAND                  CREATED              STATUS                        PORTS                          NAMES
2ad428f94fb0   gnbsim:latest                   "/gnbsim/bin/entrypo…"   33 seconds ago       Up 32 seconds (healthy)                                      gnbsim
811594cc284a   oai-upf:latest                  "/openair-upf/bin/oa…"   4 minutes ago        Up 4 minutes (healthy)        2152/udp, 8805/udp             oai-upf
ecde9367e35f   oai-smf:latest                  "/openair-smf/bin/oa…"   4 minutes ago        Up 4 minutes (healthy)        80/tcp, 8080/tcp, 8805/udp     oai-smf
68b72a425b31   trf-gen-cn5g:latest             "/bin/bash -c ' ip r…"   4 minutes ago        Up 4 minutes (healthy)                                       oai-ext-dn
57f65999d804   oai-amf:latest                  "/openair-amf/bin/oa…"   4 minutes ago        Up 4 minutes (healthy)        80/tcp, 9090/tcp, 38412/sctp   oai-amf
a44ea43b7962   mysql:8.0                       "docker-entrypoint.s…"   4 minutes ago        Up 4 minutes (healthy)        3306/tcp, 33060/tcp            mysql

```

once it's done check logs using `docker logs gnbsim`

You can see also if the UE got allocated an IP address.
```
docker-compose-host $: docker logs gnbsim 2>&1 | grep "UE address:"
[gnbsim]2023/07/13 13:01:40.584271 example.go:329: UE address: 12.1.1.2

```
## Ping test
we ping external DN from UE (gnbsim) container.

Run the following command in the terminal:
```
docker exec gnbsim ping -c 3 -I 12.1.1.2 google.com
```
```
Sample:- 

docker-compose-host $: docker exec gnbsim ping -c 3 -I 12.1.1.2 google.com
PING google.com (172.217.18.238) from 12.1.1.2 : 56(84) bytes of data.
64 bytes from par10s10-in-f238.1e100.net (172.217.18.238): icmp_seq=1 ttl=115 time=5.12 ms
64 bytes from par10s10-in-f238.1e100.net (172.217.18.238): icmp_seq=2 ttl=115 time=7.52 ms
64 bytes from par10s10-in-f238.1e100.net (172.217.18.238): icmp_seq=3 ttl=115 time=7.19 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 4ms
rtt min/avg/max/mdev = 5.119/6.606/7.515/1.064 ms
```

## iperf test
we do iperf traffic test between gnbsim UE and external DN node. We can make any node as iperf server/client.
Running iperf server on external DN container

Open separate terminals for simplicity

In one terminal make `oai-ext-dn` container the server using the command:
```
docker exec -it oai-ext-dn iperf3 -s
```
In other terminal make the gnbsim container the client using the command:
```
docker exec -it gnbsim iperf3 -c 192.168.70.135 -B 12.1.1.2
```

#### Sample test results:
- Note: the below results are for your understanding and the results will vary with every test
```
$ docker exec -it oai-ext-dn iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 12.1.1.2, port 43339
[  5] local 192.168.70.135 port 5201 connected to 12.1.1.2 port 55553
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  73.8 MBytes   619 Mbits/sec
[  5]   1.00-2.00   sec  76.3 MBytes   640 Mbits/sec
[  5]   2.00-3.00   sec  77.8 MBytes   653 Mbits/sec
[  5]   3.00-4.00   sec  66.7 MBytes   560 Mbits/sec
[  5]   4.00-5.00   sec  71.9 MBytes   603 Mbits/sec
[  5]   5.00-6.00   sec  80.2 MBytes   673 Mbits/sec
[  5]   6.00-7.00   sec  76.5 MBytes   642 Mbits/sec
[  5]   7.00-8.00   sec  78.6 MBytes   659 Mbits/sec
[  5]   8.00-9.00   sec  74.5 MBytes   625 Mbits/sec
[  5]   9.00-10.00  sec  75.5 MBytes   634 Mbits/sec
[  5]  10.00-10.01  sec   740 KBytes   719 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-10.01  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-10.01  sec   753 MBytes   631 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------

$ docker exec -it gnbsim iperf3 -c 192.168.70.135 -B 12.1.1.2
Connecting to host 192.168.70.135, port 5201
[  5] local 12.1.1.2 port 55553 connected to 192.168.70.135 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  77.6 MBytes   651 Mbits/sec   29    600 KBytes
[  5]   1.00-2.00   sec  76.2 MBytes   640 Mbits/sec    0    690 KBytes
[  5]   2.00-3.00   sec  77.5 MBytes   650 Mbits/sec    4    585 KBytes
[  5]   3.00-4.00   sec  66.2 MBytes   556 Mbits/sec  390    354 KBytes
[  5]   4.00-5.00   sec  72.5 MBytes   608 Mbits/sec    0    481 KBytes
[  5]   5.00-6.00   sec  80.0 MBytes   671 Mbits/sec    0    598 KBytes
[  5]   6.00-7.00   sec  76.2 MBytes   640 Mbits/sec    7    684 KBytes
[  5]   7.00-8.00   sec  78.8 MBytes   661 Mbits/sec    3    578 KBytes
[  5]   8.00-9.00   sec  75.0 MBytes   629 Mbits/sec    1    670 KBytes
[  5]   9.00-10.00  sec  75.0 MBytes   629 Mbits/sec    5    554 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   755 MBytes   633 Mbits/sec  439             sender
[  5]   0.00-10.00  sec   753 MBytes   631 Mbits/sec                  receiver

iperf Done.

```

## Analysing the Results
You can recover the logs like this:
```
$: docker logs oai-amf > /tmp/oai/gnbsim/amf.log 2>&1
$: docker logs oai-smf > /tmp/oai/gnbsim/smf.log 2>&1
$: docker logs oai-upf > /tmp/oai/gnbsim/upf.log 2>&1
$: docker logs gnbsim > /tmp/oai/gnbsim/gnbsim.log 2>&1
```

## Multiple UE deployment using `gnbsim`
Here we try some scaling testing with gnbsim. There are additional IMSIs added into the database (208950000000031-208950000000040). Now we create a few more gnbsim instances (2 more for now). We use the same script to generate additional instances as follow -
```
$: docker-compose -f docker-compose-gnbsim.yaml up -d gnbsim2
Creating gnbsim2 ... done

```
wait for some seconds then again execute the next
```
$: docker-compose -f docker-compose-gnbsim.yaml up -d gnbsim3
Creating gnbsim3 ... done

```
- Note: wait for one container to get healthy before starting another one
check for successfull UE IP allocation
```
$: docker logs gnbsim2 2>&1 | grep "UE address:"
[gnbsim]2024/07/26 16:45:41.584271 example.go:329: UE address: 12.1.1.3
$: docker logs gnbsim3 2>&1 | grep "UE address:"
[gnbsim]2024/07/26 16:45:42.584271 example.go:329: UE address: 12.1.1.4
```
#### Let's verify all gnb and ue are registered at our 5G core -
Use the following command to check the amf logs
```
$ docker logs oai-amf
```
```
truncated Sample output
[2024-07-28T08:59:46.513779] [AMF] [amf_app] [info ] 
[2024-07-28T08:59:46.513810] [AMF] [amf_app] [info ] |----------------------------------------------------------------------------------------------------------------|
[2024-07-28T08:59:46.513819] [AMF] [amf_app] [info ] |----------------------------------------------------gNBs' information-------------------------------------------|
[2024-07-28T08:59:46.513826] [AMF] [amf_app] [info ] |    Index    |      Status      |       Global ID       |       gNB Name       |               PLMN             |
[2024-07-28T08:59:46.513837] [AMF] [amf_app] [info ] |      1      |    Connected     |         0x400       |                 |            208, 95             | 
[2024-07-28T08:59:46.513845] [AMF] [amf_app] [info ] |      2      |    Connected     |         0x800       |                 |            208, 95             | 
[2024-07-28T08:59:46.513856] [AMF] [amf_app] [info ] |      3      |    Connected     |         0xc00       |                 |            208, 95             | 
[2024-07-28T08:59:46.513866] [AMF] [amf_app] [info ] |----------------------------------------------------------------------------------------------------------------|
[2024-07-28T08:59:46.513874] [AMF] [amf_app] [info ] 
[2024-07-28T08:59:46.513883] [AMF] [amf_app] [info ] |----------------------------------------------------------------------------------------------------------------|
[2024-07-28T08:59:46.513891] [AMF] [amf_app] [info ] |----------------------------------------------------UEs' information--------------------------------------------|
[2024-07-28T08:59:46.513900] [AMF] [amf_app] [info ] | Index |      5GMM state      |      IMSI        |     GUTI      | RAN UE NGAP ID | AMF UE ID |  PLMN   |Cell ID|
[2024-07-28T08:59:46.513911] [AMF] [amf_app] [info ] |      1|       5GMM-REGISTERED|   208950000000031|               |               0|          1| 208, 95 | 262160|
[2024-07-28T08:59:46.513923] [AMF] [amf_app] [info ] |      2|       5GMM-REGISTERED|   208950000000032|               |               0|          2| 208, 95 | 524304|
[2024-07-28T08:59:46.513931] [AMF] [amf_app] [info ] |      3|       5GMM-REGISTERED|   208950000000033|               |               0|          3| 208, 95 | 786448|
[2024-07-28T08:59:46.513938] [AMF] [amf_app] [info ] |----------------------------------------------------------------------------------------------------------------|
<<<<<<< HEAD
[2024-07-28T08:59:46.513945] [AMF] [amf_app] [info ] 
=======
[2024-07-28T08:59:46.513945] [AMF] [amf_app] [info ]
>>>>>>> f572957af645082c078cdccef4d61c5776a84268
```
### Recover the logs
You can Recover the logs for one last time 
```
$: docker logs oai-amf > /tmp/oai/gnbsim/amf.log 2>&1
$: docker logs oai-smf > /tmp/oai/gnbsim/smf.log 2>&1
$: docker logs oai-upf > /tmp/oai/gnbsim/upf.log 2>&1
$: docker logs gnbsim > /tmp/oai/gnbsim/gnbsim.log 2>&1
$: docker logs gnbsim2 > /tmp/oai/gnbsim/gnbsim2.log 2>&1
$: docker logs gnbsim3 > /tmp/oai/gnbsim/gnbsim3.log 2>&1
```

## Undeploy network functions
To Remove all the services one-by-one

Use the following command to stop all instances of gnbsim
```
docker compose -f docker-compose-gnbsim.yaml down
```
Now let's undeploy the core

Run the following command to undeploy core-services
```
sudo python3 core-network.py --type stop-basic
```
Everything is now shut down

### End of tutorial

On-going work : automating the connectivity of the gnbsim process using bash script or docker services
