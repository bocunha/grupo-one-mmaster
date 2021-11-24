#!/bin/bash
## VARIAVEIS
TFPATH="$PWD"
CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
CHAVESSH="/var/lib/jenkins/.ssh/grupo-one.pem"
AMIID="cat /tmp/k8s-ami-id.tmp"
###########################

cd $TFPATH/0-terraform/

CHKTFOUTPUT=$(terraform output | wc -l)

if [ ${CHKTFOUTPUT} -lt 25 ]; 
  then
  echo "TERRAFORM INCOMPLETO OU DESTRUIDO"
  exit 1
fi

#PEGA O ESTADO DO TERRAFORM
cd $TFPATH/0-terraform/

### RETIRA OS IPS E DNS DAS MAQUINAS
terraform output | sed 's/\",//g' > $TFPATH/tmp/tfoutput.tmp

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


# COLOCA A INFRMACAO DOS IPS NO HOSTS DO ANSIBLE
echo "
[ec2-k8s-proxy]
$ID_HAPROXY_DNS

[ec2-k8s-m1]
$ID_M1_DNS
[ec2-k8s-m2]
$ID_M2_DNS
[ec2-k8s-m3]
$ID_M3_DNS

[ec2-k8s-w1]
$ID_W1_DNS
[ec2-k8s-w2]
$ID_W2_DNS
[ec2-k8s-w3]
$ID_W3_DNS

" > $TFPATH/2-ansible/01-k8s-install-masters_e_workers/hosts

cat $TFPATH/2-ansible/01-k8s-install-masters_e_workers/hosts
####################
### SEGUE PARA O SCRIPT haproxy.sh