#!/bin/bash -vx
## VARIAVEIS
TFPATH="$PWD"
CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
CHAVESSH="~/.ssh/grupo-one.pem"
AMIID="cat /tmp/k8s-ami-id.tmp"
###########################

#PEGA O ESTADO DO TERRAFORM
cd $TFPATH/2-ansible/01-k8s-install-masters_e_workers

ID_M1_DNS=`awk '/IP k8s-master azc1 -/ {print $8}' $TFPATH/tmp/tfoutput.tmp | cut -d"@" -f2`

echo "STATUS DOS NODES"
GETNODES=$(ssh -i ${CHAVESSH} ubuntu@${ID_M1_DNS} 'sudo kubectl get nodes' | grep -i ready | wc -l )

if [[ $GETNODES -eq 6 ]]
then 
    echo "::::: server está no ar :::::"
    exit 0
else
    echo "::::: server não está no ar :::::"
    exit 1
fi