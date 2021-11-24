#!/bin/bash
## VARIAVEIS
TFPATH="$PWD"
CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
CHAVESSH="/var/lib/jenkins/.ssh/grupo-one.pem"
AMIID="cat /tmp/k8s-ami-id.tmp"
###########################

sleep 20 
ID_M1=`awk '/IP k8s-master azc1 -/ {print $5}' $TFPATH/tmp/tfoutput.tmp`
ID_M1_DNS=`awk '/IP k8s-master azc1 -/ {print $8}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`

ID_M2=`awk '/IP k8s-master aza2 -/ {print $5}' $TFPATH/tmp/tfoutput.tmp`
ID_M2_DNS=`awk '/IP k8s-master aza2 -/ {print $8}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`

ID_M3=`awk '/IP k8s-master azc3 -/ {print $5}' $TFPATH/tmp/tfoutput.tmp`
ID_M3_DNS=`awk '/IP k8s-master azc3 -/ {print $8}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`

ID_HAPROXY=`awk '/k8s_proxy -/ {print $3}' $TFPATH/tmp/tfoutput.tmp`
ID_HAPROXY_DNS=`awk '/k8s_proxy -/ {print $6}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`

ID_W1=`awk '/IP k8s-workers azc1 -/ {print $5}' $TFPATH/tmp/tfoutput.tmp`
ID_W1_DNS=`awk '/IP k8s-workers azc1 -/ {print $8}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`

ID_W2=`awk '/IP k8s-workers aza2 -/ {print $5}' $TFPATH/tmp/tfoutput.tmp`
ID_W2_DNS=`awk '/IP k8s-workers aza2 -/ {print $8}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`

ID_W3=`awk '/IP k8s-workers azc3 -/ {print $5}' $TFPATH/tmp/tfoutput.tmp`
ID_W3_DNS=`awk '/IP k8s-workers azc3 -/ {print $8}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`


#PEGA O ESTADO DO TERRAFORM
cd $TFPATH/0-terraform/

#CRIA SCRIPT DO ANSBILE PARA SUBIR O HAPROXY
echo "
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

frontend kubernetes
        mode tcp
        bind $ID_HAPROXY:6443 # IP ec2 Haproxy 
        option tcplog
        default_backend k8s-masters

backend k8s-masters
        mode tcp
        balance roundrobin # maq1, maq2, maq3  # (check) verifica 3 vezes negativo (rise) verifica 2 vezes positivo
        server k8s-master-0 $ID_M1:6443 check fall 3 rise 2 # IP ec2 Cluster Master k8s - 1 
        server k8s-master-1 $ID_M2:6443 check fall 3 rise 2 # IP ec2 Cluster Master k8s - 2 
        server k8s-master-2 $ID_M3:6443 check fall 3 rise 2 # IP ec2 Cluster Master k8s - 3 
        
" > $TFPATH/2-ansible/01-k8s-install-masters_e_workers/haproxy/haproxy.cfg

echo "
127.0.0.1 localhost
$ID_HAPROXY k8s-haproxy # IP privado proxy

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
" > $TFPATH/2-ansible/01-k8s-install-masters_e_workers/host/hosts

##########################################################
##########################################################
##########################################################
## RODA O ANSBILE PLAYBOOK PARA PROVISIONAR AS MAQUINAS
cd $TFPATH/2-ansible/01-k8s-install-masters_e_workers

ansible-playbook -i hosts haproxy.yml -u ubuntu --private-key ${CHAVESSH}

############################
### VAI PARA k8s.sh