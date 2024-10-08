# IDS-Lab
IDS and detections lab infrastructure deployable as docker containers.

![IDS Lab schema](./docs/ids-lab.png "IDS Lab schema")

# Prerequisites

* `docker-compose`
* `bash`
* `curl`
* `tar`
* `ip`
* `pwgen` or `openssl`
* some basic utils: `sort`, `wc`, `grep`, `sed`
* *(optional)* `jq`

# Setup

## Automatic setup

Clone this repository and run `setup-ids-lab.sh`:

```
git clone https://github.com/SecurityDungeon/ids-lab.git
cd ids-lab
./setup-ids-lab.sh
```

### Local/public mode

There are two setup modes available: `local` and `public`. The setup mode is determined by `-m` option of `setup-ids-lab.sh` script. By default, the local mode is used:
- in local mode, the IDS-Lab is listening only on localhost intefrace (127.0.0.1). Suitable for deploying IDS-Lab on your computer.
- in public mode, the IDS-Lab is listening on all interfaces of the host. Suitable for deploying IDS-Lab on Virtual Machine (VM) or Virtual Private Server (VPS) or some public server. Be careful, in docker usually bypasses your local firewall rules (e.g. iptables) by adding its own rules.

```
$ ./setup-ids-lab.sh -h

Usage: ./setup-ids-lab.sh [-m local|public]

Options:
	-m mode		setup mode of IDS-Lab
                        available modes:
                        local: (default) listen only on localhost, recommended for local setup on host machine
			public: listen on all interfaces, recommended for setup in virtual machine or VPS
                                Be careful, docker bypasses your iptables rules
	-h		show this help
```

## Automatic setup - oneliner
If you prefer oneliner, you can download and run the setup script and it will create ids-lab in current directory:

```
curl -s https://raw.githubusercontent.com/SecurityDungeon/ids-lab/refs/heads/main/setup-ids-lab.sh | bash
```

## Manual setup
Download this repository (with  `curl` as in example below, or just use `git clone`). Create a copy of environment file from `.env.model` and populate it with your values and secrets. Then generate self-signed certificate for local domain `*.ids-lab.home.arpa` and deploy the lab with `docker-compose`. Finally, setup the OpenObserve dashboards and saved views with `setup-openobserve.sh`:

```
curl https://github.com/SecurityDungeon/ids-lab/archive/refs/heads/main.tar.gz --output ids-lab-main.tar.gz
tar xzvf ids-lab-main.tar.gz
cd ids-lab
cp .env.model .env
<edit> .env
openssl req -x509 -newkey rsa:4096 -keyout ./nginx/ssl/privkey.pem -out ./nginx/ssl/fullchain.pem -sha256 -days 3650 -nodes -subj "/CN=*.ids-lab.home.arpa"
docker-compose build
docker-compose up --no-start
docker-compose start
./setup-openobserbe.sh
```



After end, the infrastructure can be stopped with `docker-compose stop` and containers can be deleted with `docker-compose down`.
All created volumes and downloaded images can be deleted with `docker-compose down --volumes --rmi all`.

```
docker-compose stop # stop docker containers
docker-compose down # stop and delete docker containers
docker-compose down --volumes # stop and delete docker containers and volumes
docker-compose down --volumes --rmi all # stop and delete docker containers, volumes and images
```

# Services
If you want to access the services also via HTTPs (with self-signed certificate), add the following entry to your `/etc/hosts` file:

```
127.0.0.1	www.ids-lab.home.arpa siem.ids-lab.home.arpa wg.ids-lab.home.arpa kali.ids-lab.home.arpa
```

#### Services available from host
* [Kali Linux](https://hub.docker.com/u/kalilinux/) [http://127.0.0.1:1337](http://127.0.0.1:1337), [https://kali.ids-lab.home.arpa](https://kali.ids-lab.home.arpa)
  * kali linux with web-based terminal emulator for performing the attacks
* [Nginx](https://hub.docker.com/_/nginx) [http://127.0.0.1:80](http://127.0.0.1:80), [https://www.ids-lab.home.arpa](https://www.ids-lab.home.arpa)
  * webserver and reverse-proxy for exposing other webapps
* [WordPress](https://hub.docker.com/_/wordpress) [http://127.0.0.1:80](http://127.0.0.1:80), [https://www.ids-lab.home.arpa](https://www.ids-lab.home.arpa)
  * exposed via nginx container
  * ready to setup
* [OpenObserve](https://github.com/openobserve/openobserve/) (SIEM) for Students: [http://127.0.0.1:8080](http://127.0.0.1:8080), [https://siem.ids-lab.home.arpa](https://siem.ids-lab.home.arpa)
  * exposed via nginx container
  * dangerous features hidden (e.g. streams, pipelines, IAM)
  * `lab` organization with alerts and flows from Suricata and Apache logs from WordPress
* [OpenObserve](https://github.com/openobserve/openobserve/) (SIEM) for Admin: [http://127.0.0.1:5080](http://127.0.0.1:5080)
  * all features visible
  * `admin` organization with all logs from Suricata and other Docker containers
* [WireGuard UI](https://github.com/ngoduykhanh/wireguard-ui): [http://127.0.0.1:5000](http://127.0.0.1:5000), [https://wg.ids-lab.home.arpa](https://wg.ids-lab.home.arpa)
  * web-ui management for WireGuard clients
* [WireGuard](https://hub.docker.com/r/linuxserver/wireguard) server: [udp://0.0.0.0:51820](udp://0.0.0.0:51820)
  * available for connecting other machines (e.g. attacker or students) for direct access to the Docker containers
* [Fluent Bit](https://hub.docker.com/r/fluent/fluent-bit/): [tcp://127.0.0.1:24224](tcp://127.0.0.1:24224) and [udp://127.0.0.1:24224](udp://127.0.0.1:24224)
  * lightweight log processor
  
#### Services available only from Docker network
* [MySQL](https://hub.docker.com/_/mysql): [tcp://mysql:3306](tcp://mysql:3306)
  * database
* [Linux Desktop](https://hub.docker.com/r/linuxserver/rdesktop): [rdp://accounting:3389](rdp://accounting:3389)
  * with OpenBox and RDesktop
* [Suricata](https://github.com/jasonish/docker-suricata)
  * Network IDS with alerts and flows
