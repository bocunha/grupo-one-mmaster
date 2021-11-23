#!/bin/bash
## VARIAVEIS
TFPATH="$PWD"
CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
CHAVESSH="/var/lib/jenkins/.ssh/grupo-one.pem"
AMIID=`cat /tmp/k8s-ami-id.tmp`
###########################

cd $TFPATH/0-terraform/
mv sg-ok.tf $TFPATH/tmp/sg-ok.tf.bkp
cp sg-nok.tf.bkp sg-nok.tf
terraform init
TF_VAR_amiid=$AMIID terraform apply -auto-approve
sleep 5
TF_VAR_amiid=$AMIID terraform destroy -auto-approve