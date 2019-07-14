Title: Non-transparent proxy with Squid and Docker
Date: 2018-08-30
Modified: 2018-08-30
Category: Networking
Tags: squid, proxy, http, https, ssl, docker
Authors: Finite Elemente
Summary: deploy non-transparent squid in docker for network monitoring and filtering 

We are looking to create a non-transparent proxy server using Squid for networking sniffing. The end product should be able to sniff both HTTP and HTTPS traffic. 

# Transparent proxy server vs non-transparent proxy server

Both types proxy servers are able to relay traffic from client machine. Transparent proxy is the easier setup. It allows quick access to the web for everyone without configuration from client side. 

The down side of a transparent proxy is that it provides limited function to perform network traffic monitoring and filtering. Only HTTP traffic can be monitored. 

A non-transparent proxy on the other hand, provides a much more powerful and flexible proxying service. It can relay HTTPS traffic as a man-in-the-middle proxy by forging its own SSL certificate. However, in order to achieve this, server's CA certificate must be installed and trusted as a root certificate on client's machine. 

In this project, we will explorer setting up a non-transparent proxy server using squid and containerize it into a docker. This container can later be used with an ICAP service to perform network traffic filtering in the future. 

# Squid docker

A popular proxy software, [link](http://www.squid-cache.org/). The `Dockerfile` is created and the content is as followed.


```
FROM ubuntu:18.04

ENV SQUID_VERSION=3.5.27 \
    SQUID_DIR=/usr/local/squid \
    SQUID_USER=proxy

RUN apt-get update
RUN apt-get install build-essential openssl libssl1.0-dev wget -y

WORKDIR /tmp
RUN wget http://www.squid-cache.org/Versions/v3/3.5/squid-${SQUID_VERSION}.tar.gz
RUN tar -xzf squid-${SQUID_VERSION}.tar.gz
WORKDIR /tmp/squid-${SQUID_VERSION}

RUN chmod +x configure
RUN ./configure \
        --datadir=/usr/share/squid \
        --sysconfdir=/etc/squid \
        --libexecdir=/usr/lib/squid \
        --with-pidfile=/var/run/squid.pid \
        --with-filedescriptors=65536 \
        --with-large-files \
        --enable-delay-pools \
        --enable-cache-digests \
        --enable-icap-client \
        --enable-ssl \
        --enable-ssl-crtd \
        --with-openssl \
        --enable-follow-x-forwarded-for \
        --with-default-user=${SQUID_USER}
RUN make
RUN make install

ENV PATH=$PATH:/usr/local/squid/sbin
RUN /usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db # SSL certificate database directory

RUN mkdir -p ${SQUID_DIR}
RUN chmod -R 755 ${SQUID_DIR}
RUN chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_DIR}
RUN chown -R ${SQUID_USER}:${SQUID_USER} /usr/lib/squid/ssl_crtd

EXPOSE 3128/tcp
```


In addition to the `Dockerfile`, there are 5 more files that are important. 

```
/usr/local/squid/var/cache  # cache
/usr/local/squid/var/logs   # logs
/etc/squid/squid.conf       # squid configuration file
/usr/local/squid/ca.crt     # ssl certificate
/usr/local/squid/ca.key     # ssl private key
```

These files will be mapped to the host system in `docker-compose.yml` file. 

`ca.crt` and `ca.key` are our server SSL certificate and keys. They can be generated using this script. 

```
#!/bin/sh

openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/CN=XXXXX CA"
openssl genrsa -out cert.key 2048
```

Replace `XXXXX` with the name at your choice. 

`squid.conf` is squid configuration file. Here is an example

```
#defaults
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localnet src fc00::/7
acl localnet src fe80::/10
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT

http_access allow manager localhost
http_access deny manager
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localnet
http_access allow localhost     # allow traffic from localhost


# to allow other client IP, set them up above
http_access deny all


#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#

cache_effective_user proxy
cache_effective_group proxy

# this work for both http and https traffic
http_port 3128 ssl-bump generate-host-certificates=on \
    dynamic_cert_mem_cache_size=4MB \
    cert=/usr/local/squid/ca.crt \
    key=/usr/local/squid/ca.key

#always_direct allow all
ssl_bump server-first all

#sslproxy_cert_error deny all
sslproxy_flags DONT_VERIFY_PEER

sslcrtd_program /usr/lib/squid/ssl_crtd -s /var/lib/ssl_db -M 4MB
sslcrtd_children 8 startup=1 idle=1

# icap filtering service
icap_enable on
icap_preview_enable on

# request filtering, set bypass to 0 to enforce
icap_service service_req reqmod_precache bypass=1 icap://icap:1344
adaptation_access service_req allow all

# response filtering, set bypass to 0 to enforce
icap_service service_resp respmod_precache bypass=1 icap://icap:1344
adaptation_access service_resp allow all

#
# Add any of your own refresh_pattern entries above these.
#
refresh_pattern ^ftp:       1440    20% 10080
refresh_pattern ^gopher:    1440    0%  1440
refresh_pattern -i (/cgi-bin/|\?) 0 0%  0
refresh_pattern .       0   20% 4320

shutdown_lifetime 1 second
```


At last, the `docker-compose.yml` that puts everything together. 

```
version: '3'

services:
  squid:
    build: ./
    ports:
      - "8888:3128"
    volumes:
      - ./cache:/usr/local/squid/var/cache
      - ./logs:/usr/local/squid/var/logs
      - ./squid.conf:/etc/squid/squid.conf
      - ./ca.crt:/usr/local/squid/ca.crt
      - ./ca.key:/usr/local/squid/ca.key
    restart: always
    command: squid -f /etc/squid/squid.conf -NYCd 1
```

The folder structure should look like this:


```

squid/
    ca.crt
    ca.key
    cert.key
    docker-compose.yml
    Dockerfile
    squid.conf
    cache/
    logs/

```

Start the squid docker by running `docker-compose up`. Docker should start building the docker image. At the very end, the console should have a print out like this. 

```
Creating squid_squid_1 ... done                                                                                                        
Attaching to squid_squid_1                                                                                                             
squid_1  | 2018/09/01 02:33:39| Current Directory is /tmp/squid-3.5.27                                                                 
squid_1  | 2018/09/01 02:33:39| Starting Squid Cache version 3.5.27 for x86_64-pc-linux-gnu...                                         
squid_1  | 2018/09/01 02:33:39| Service Name: squid                                                                                    
squid_1  | 2018/09/01 02:33:39| Process ID 1                                                                                           
squid_1  | 2018/09/01 02:33:39| Process Roles: master worker                                                                           
squid_1  | 2018/09/01 02:33:39| With 1048576 file descriptors available                                                                
squid_1  | 2018/09/01 02:33:39| Initializing IP Cache...                                                                               
squid_1  | 2018/09/01 02:33:39| DNS Socket created at [::], FD 9                                                                       
squid_1  | 2018/09/01 02:33:39| DNS Socket created at 0.0.0.0, FD 10                                                                   
squid_1  | 2018/09/01 02:33:39| Adding nameserver 127.0.0.11 from /etc/resolv.conf                                                     
squid_1  | 2018/09/01 02:33:39| Adding ndots 1 from /etc/resolv.conf                                                                   
squid_1  | 2018/09/01 02:33:39| helperOpenServers: Starting 1/8 'ssl_crtd' processes                                                   
squid_1  | 2018/09/01 02:33:39| Logfile: opening log daemon:/usr/local/squid/var/logs/access.log                                       
squid_1  | 2018/09/01 02:33:39| Logfile Daemon: opening log /usr/local/squid/var/logs/access.log                                       
squid_1  | 2018/09/01 02:33:39| Local cache digest enabled; rebuild/rewrite every 3600/3600 sec                                        
squid_1  | 2018/09/01 02:33:39| Store logging disabled                                                                                 
squid_1  | 2018/09/01 02:33:39| Swap maxSize 0 + 262144 KB, estimated 20164 objects                                                    
squid_1  | 2018/09/01 02:33:39| Target number of buckets: 1008                                                                         
squid_1  | 2018/09/01 02:33:39| Using 8192 Store buckets                                                                               
squid_1  | 2018/09/01 02:33:39| Max Mem  size: 262144 KB                                                                               
squid_1  | 2018/09/01 02:33:39| Max Swap size: 0 KB                                                                                    
squid_1  | 2018/09/01 02:33:39| Using Least Load store dir selection                                                                   
squid_1  | 2018/09/01 02:33:39| Current Directory is /tmp/squid-3.5.27                                                                 
squid_1  | 2018/09/01 02:33:39| Finished loading MIME types and icons.                                                                 
squid_1  | 2018/09/01 02:33:39| HTCP Disabled.                                                                                         
squid_1  | 2018/09/01 02:33:39| Squid plugin modules loaded: 0                                                                         
squid_1  | 2018/09/01 02:33:39| Adaptation support is on                                                                               
squid_1  | 2018/09/01 02:33:39| Accepting SSL bumped HTTP Socket connections at local=[::]:3128 remote=[::] FD 16 flags=9              
squid_1  | 2018/09/01 02:33:40| storeLateRelease: released 0 objects                                                                   
```


# Client setup

On client machine, install the server certificate `ca.crt` as Trusted Root Certification Authorities, refer to [Windows and Linux](https://success.outsystems.com/Support/Enterprise_Customers/Installation/Install_a_trusted_root_CA__or_self-signed_certificate), and [Mac](https://pubs.vmware.com/flex-1/index.jsp?topic=%2Fcom.vmware.horizon.flex.admin.doc%2FGUID-9201A917-D476-40EF-B1F4-BBF14AB83D94.html).

Configure the proxy setting on your machine to ip `localhost` and port `8888`. If the client is on a different machine, you need to open port `8888` on the server side and configure client to the server's ip and port `8888`. 

Once everything configured, go to google.ca and check its SSL certificate, the certificate should say its issued by XXXXX instead of Google. But all certificate encryption and signature should be valid as we have trusted our own CA certificate on the client machine. 


