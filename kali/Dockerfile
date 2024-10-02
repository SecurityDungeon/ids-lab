FROM kalilinux/kali-rolling:latest
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      shellinabox \
      net-tools \
      bind9-dnsutils \
      inetutils-ping \
      inetutils-traceroute \
      netcat-traditional \
      curl \
      wget \
      links \
      vim \
      nmap \
      nikto \
      wpscan \
      sqlmap 
COPY  ../nginx/ssl/fullchain.pem /usr/local/share/ca-certificates/ids-lab.crt
RUN update-ca-certificates
CMD ["/bin/bash"]
