
# OpenAirInterface v1.4.0 - Core and testing with RAN simulator GNBSIM
The following setup is taken from the repo : https://github.com/5g-ucl-idrbt/oai-core

You can check that out for a virtualised core and a physical USRP setup
## Description
The target [Architectural diagram](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/raw/master/docs/images/5gCN_gnbsim.jpg) has two parts. `(a) Virtualized 5G Core` and `(b) RAN simulator GNBSIM`. This tutorial is about how to create Virtualized 5G Core VM along with RAN simulator `GNBSIM`

## Tested Setup
We have used this on :
- `Intel Core I7 13th gen system`
- `Ryzen 5 3500H system`
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

# To be continued
- Automating multiple UE connection using gnbsim
- current status: bash script (check generator.sh and start_containers.sh) `cd docker-compose`
- aim: to generate multiple UEs using docker's features (on-going will be pushed soon)
