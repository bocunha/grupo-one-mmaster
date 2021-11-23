#!/bin/bash -vx
## VARIAVEIS
TFPATH="/home/ec2-user/cluster-multi-master/0-k8s"
CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
CHAVESSH="~/.ssh/ortaleb-chave-nova.pem"
AMIID=`cat /tmp/k8s-ami-id.tmp`
###########################

cd $TFPATH/0-terraform/
mv sg-ok.tf $TFPATH/tmp/sg-ok.tf.bkp
cp sg-nok.tf.bkp sg-nok.tf
terraform init
TF_VAR_amiid=$AMIID terraform apply -auto-approve
sleep 5
TF_VAR_amiid=$AMIID terraform terraform destroy -auto-approve