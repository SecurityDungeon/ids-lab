#!/bin/bash

set -u
set -e

help() {
    echo "
Usage: $0 [-m local|public]

Options:
	-m mode		setup mode of IDS-Lab
                        available modes:
                        local: (default) listen only on localhost, recommended for local setup on host machine
			public: listen on all interfaces, recommended for setup in virtual machine or VPS
                                Be careful, docker bypasses your iptables rules
	-h		show this help
    "
    exit 1
}

mode="local"
while getopts ":m:" opt; do
    case ${opt} in
        m) mode=$OPTARG ;;
	*) help ;;
    esac
done
	
echo "Setup IDS-Lab start"
echo "Setup mode: ${mode}"

echo "Checking dependencies..."
missing_dependency=0
for program in docker-compose curl tar ip sort wc grep sed
do
    if ! command -v ${program} 2>&1 >/dev/null
    then
        echo "${program} not found"
        missing_dependency=1
    fi
done
if command -v pwgen 2>&1 >/dev/null
then
    pwgen="pwgen --capitalize --numerals --ambiguous 27 1"
else
    if command -v openssl 2>&1 >/dev/null
    then
        pwgen="openssl rand -hex 20"
    else
        echo "openssl and pwgen missing - at least one of them is needed for generating passwords"
        missing_dependency=1
    fi
fi
if [[ ${missing_dependency} -ne 0 ]]
then
    echo "Please install missing dependencies"
    echo "Setup IDS-Lab fail"
    exit 1
fi

echo "Checking IDS-Lab files..."
if [[ -f ../ids-lab/.gitignore ]]
then 
    echo "We are already in ids-lab repository. Skipping download"
else
    if [[ -f ../ids-lab/.gitignore ]]
    then
        echo "Repository ids-lab found in current directory. Skipping download"
    else
        echo "Downloading IDS-Lab files to the current directory"
        curl --silent --location https://github.com/SecurityDungeon/ids-lab/archive/refs/heads/main.tar.gz --output ids-lab-main.tar.gz 
        tar xzf ids-lab-main.tar.gz
        mv ids-lab-main ids-lab
    fi
    cd ids-lab
fi

echo "Checking running containers from IDS-Lab..."
number_of_containers=$(docker-compose ps --quiet | wc -l)
if [[ ${number_of_containers} -gt 0 ]]
then
    echo "Running containers found, stopping them..."
    docker-compose stop
fi

echo "Checking environment and local config..."
if [[ -f .env ]]
then
    echo "Found .env file, no modifications of secrets will be done"
else
    echo "Preparing secrets in .env file"
    cp .env.model .env
    templates=$(grep -o "%.*%" .env | sort -u)
    for template in ${templates}
    do
        password=$(${pwgen})
        sed -i -e "s/${template}/${password}/g" .env
    done
fi
if [[ -f ./nginx/ssl/privkey.pem ]] && [[ -f ./nginx/ssl/fullchain.pem ]]
then
    echo "Found previous TLS private key and certificate"
else
    echo "Generating TLS private key and certificate for *.ids-lab.home.arpa"
    openssl req -x509 -newkey rsa:4096 -keyout ./nginx/ssl/privkey.pem -out ./nginx/ssl/fullchain.pem -sha256 -days 3650 -nodes -subj "/CN=*.ids-lab.home.arpa"
fi

if [[ ${mode} = "public" ]]
then
	echo "Adjust docker-compose.yml for public mode..."
	sed -i -e 's/127.0.0.1:\(1337:\|80:\|8080:\|443:\|5000:\|5080:\|51820:\)/0.0.0.0:\1/g' docker-compose.yml
fi

echo "Building custom docker images for IDS-Lab..."
docker-compose build

echo "Creating IDS-Lab networks and containers..."
docker-compose up --no-start

echo "Starting IDS-Lab containers"
docker-compose start

echo "Setup OpenObserve..."
./setup-openobserve.sh

echo "Running containers:"
docker-compose ps

echo
echo "Please add to your /etc/hosts the following line:"
if [[ ${mode} = "local" ]]
then
    ip="127.0.0.1"
else
    ip=$(ip route get 1.1.1.1 | grep -o 'src [0-9\.]\+ ' | grep -o '[0-9\.]\+')
fi
echo "${ip}	www.ids-lab.home.arpa siem.ids-lab.home.arpa wg.ids-lab.home.arpa kali.ids-lab.home.arpa"
echo "(optionally, you can use the IP address of your another interface if you wish)"

source .env
echo
echo "Available services and credentials:
    Kali Linux for 'attacker':
        http://${ip}:1337
	https://kali.ids-lab.home.arpa
	user: root
	pass: ${KALI_PASSWORD}
    WordPress (ready for install)
        http://${ip}:80
	https://www.ids-lab.home.arpa
    OpenObserve SIEM for students:
        http://${ip}:8080
	https://siem.ids-lab.home.arpa
	user: ${ZO_STUDENT_USER_EMAIL}
	pass: ${ZO_STUDENT_USER_PASSWORD}
    OpenObserve SIEM for admin:
        http://${ip}:8080
	user: ${ZO_ROOT_USER_EMAIL}
	pass: ${ZO_ROOT_USER_PASSWORD}
    WireGuard server:
        udp://${ip}:51820
    WireGuard web management:
        http://${ip}:5000
	https://wg.ids-lab.home.arpa
	user: ${WGUI_USERNAME}
	pass: ${WGUI_PASSWORD}
"

echo "Setup IDS-Lab end"
